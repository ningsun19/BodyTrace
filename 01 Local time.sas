*ODS statements -- pending to be added; 
/* Date: July 6, 2022 */ 

/* Fit&Quit */
/* BodyTrace data */
/* Ning Sun (NS) */
/* Wupeng (W); 
/* Stephanie Garcia (SG) */

/*Items completed thus far: */ 
/* Tried the two data cleaning method provided */

/* libname bodytrac 'C:\Users\sjagarci\OneDrive - Florida International University\FIU-STATCONSULT\CONSULTATIONS\Krukowski, Becca_Body Trace\data';  */

data BODY100.fq_bodytrace1; 
set BODY100.fq_bodytrace;
if weight=. then delete;
if timezone='A' then timezone='M';
run;
/*SG: Recode missing timezone to C -- confirm with instructions?? YES*/
/*SG: orginal number of observations: 142033*/
/*NS: removed 30774 observations as MISSING, remaining 111259*/

proc sort data=BODY100.fq_bodytrace1;
by studyid date time;
run;

proc freq data=BODY100.fq_bodytrace1;
tables timezone;
run;

data BODY100.fq_bodytrace1;
set BODY100.fq_bodytrace1;
if weight < 22.7 then delete; 
run; 

/*SG: Original bodytrac1 observations: 111259*/
/*NS: removed 5791 biologically impossible observations, remaining 105468 */

proc sql;
select count(studyid) as n from
	(select distinct studyid from BODY100.fq_bodytrace1);
quit;
/*NS: There were 301 IDs */


/* Earliest date and last date in variable "DATE" */
proc means data=bodytrac.fq_bodytrace1 min max noprint;
    var date;
output out=new(drop=_type_ _freq_) min= max= / autoname;
run;


/* Beginning date and quit date for each "STUDYID" */
proc sql;
select studyid,
 min(date) as min_date format=mmddyy10.,
 max(date) as max_date format=mmddyy10.
from bodytrac.fq_bodytrace1
group by studyid;
quit;

* NS: why we need this for everyone? ;

/* WY: All zip codes, 332 missing (all for studyid = 517) */
/* WY: studyid = 517 doesn't have time zone either. But we consider it was central time? */

proc freq data=bodytrac.fq_bodytrace1;
tables addresszip;
run;

proc sql;
select studyid, nmiss(addresszip) as nmiss_zipcode
    from bodytrac.fq_bodytrace1
    group by studyid;
quit;

proc sql;
select count(*) as N_obs
from bodytrac.fq_bodytrace1
where studyid=517;
quit;

/* Now Arizona */
/* We search the zip codes range belongs to Arizona state, because not all part of Arizona are MST. */
/* Arizona does not observe Daylight Savings, with the exception of the Navajo Nation. */
/* We found 85138 is the only zip code belongs to Maricopa County, Arizona. */
/* Maricopa County, Arizona does not utilize Daylight Saving Time. */
/* Therefore, 85138 is MST for all observations. */

proc sql; 
select distinct studyid, addresszip as ArizonaZip
from bodytrac.fq_bodytrace1 
where addresszip > 85001 and addresszip < 86556; 
quit;

/*************************************/
/* Change all empty time zone to "C" */
/*************************************/

data BODY100.fq_bodytrace2; 
set BODY100.fq_bodytrace1;
if timezone='' then timezone='C';
run;

/********************************/
/* Change All GMT to Local Time */
/********************************/
proc sql;
   create table LocalDatetime_df like BODY100.fq_bodytrace2;
   insert into LocalDatetime_df
   select * from BODY100.fq_bodytrace2;
   alter table LocalDatetime_df
      add GMT num label = 'GMT' format = datetime20.
      add Local_datetime num label = 'Local_datetime' format = datetime20.
      add Local_timezone char label='Local_timezone'
      add Local_Date num label = 'Local_Date' format = MMDDYY10.
      add Local_Time num label='Local_Time' format = TIME20.3
      add dst_datebeg_GMT num label = 'dst_datebeg_GMT' format = mmddyy10.
      add dst_dateend_GMT num label = 'dst_dateend_GMT' format = mmddyy10.
      add dst_time_GMT num label = 'dst_time_GMT' format = TIME20.3
      add dst_datetimebeg_GMT num label = 'dst_datetimebeg_GMT' format = datetime20.
      add dst_datetimeend_GMT num label = 'dst_datetimeend_GMT' format = datetime20.;
   update LocalDatetime_df
   set dst_datebeg_GMT = nwkdom(2, 1, 3, year(date)), 
       dst_dateend_GMT = nwkdom(1, 1, 11, year(date)),
       dst_time_GMT = case
                         when timezone = 'E' then '06:00:00't
                         when timezone = 'C' then '07:00:00't
                         when timezone = 'M' then '08:00:00't
                         when timezone = 'P' then '09:00:00't
                         else dst_time_GMT
                         end;
   update LocalDatetime_df                      
   set dst_datetimebeg_GMT = dhms(dst_datebeg_GMT, 0, 0, dst_time_GMT),
       dst_datetimeend_GMT = dhms(dst_dateend_GMT, 0, 0, dst_time_GMT),
       GMT = dhms(date, 0, 0, time);
   update LocalDatetime_df                      
   set Local_timezone = case
                           when studyid eq 2484 then "MST"
                           else
                              case
                                 when GMT between dst_datetimebeg_GMT and dst_datetimeend_GMT then
                                    case 
                                       when timezone = 'E' then 'EDT'
                                       when timezone = 'C' then 'CDT'
                                       when timezone = 'M' then 'MDT'
                                       when timezone = 'P' then 'PDT'
                                       else Local_timezone
                                    end
                                 else
                                    case
                                       when timezone = 'E' then 'EST'
                                       when timezone = 'C' then 'CST'
                                       when timezone = 'M' then 'MST'
                                       when timezone = 'P' then 'PST'
                                       else Local_timezone
                                    end
                              end
                        end;
   update LocalDatetime_df
   set Local_datetime = case
                           when Local_timezone = 'EDT' then 
                              intnx("HOUR", GMT, -4, "SAME")
                           when Local_timezone in ('CDT', 'EST') then 
                              intnx("HOUR", GMT, -5, "SAME")
                           when Local_timezone in ('MDT', 'CST') then 
                              intnx("HOUR", GMT, -6, "SAME")
                           when Local_timezone in ('PDT', 'MST') then 
                              intnx("HOUR", GMT, -7, "SAME")
                           when Local_timezone = 'PST' then 
                              intnx("HOUR", GMT, -8, "SAME")
                           else Local_datetime
                       end;
   update LocalDatetime_df
   set Local_Date = datepart(Local_datetime),
       Local_time = timepart(Local_datetime);
                   
quit;


/*************************************/
/**************** NOTE ***************/
/*************************************/

/* (1) studyid = 2484 (Arizona 85138, MST ONLY) */
/* (2) studyid = 517 doesn't have zip code & timezone. 
       But based on Dr. Bursac's requirement, we consider 
       it was in central time (CDT or CST). */



/*******************************************/
/*     Local Date and Time in 365 Days     */
/*******************************************/

proc sql;
	create table sortdata
	as select *
	from body100.localdatetime_df
	order by studyid, Local_datetime;
quit;

data localdatetime_365_r1;
   set sortdata;
   by studyid;
   if FIRST.studyid then 
      do;
         firstDate = Local_Date; 
         num_days = intck('day', firstDate, Local_Date);
         id_nofobs = 1;
         retain firstDate id_nofobs;
         output;
      end;
   else 
      do;
         num_days = intck('day', firstDate, Local_Date);
         id_nofobs = id_nofobs + 1;
         output;
      end;
   format firstDate mmddyy10.;
run;

data BODY100.localdatetime_365;
   set work.localdatetime_365_r1;
   if num_days > 365 then delete; 
run;

proc freq data = body100.localdatetime_365;
   table studyid / nopercent nocum;
   run;
