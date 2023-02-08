/************************************/
/************************************/
/************************************/
/*          Post-Outliers           */
/************************************/
/************************************/
/************************************/

data temp1;
   set BODY100.cleandf_use;
   if num_days = 365 then delete; 
run;

data temp2;
   set temp1;
   num_days = num_days + 1;
run;

/*******************************************************/
/*     
       Q6: Sort the data by id, date & time  
                                                       */
/*******************************************************/
proc sql;
	create table sortdata
	as select *
	from temp2
	order by studyid asc, Local_datetime asc;
quit;

/*******************************************************/
/*     
       Q7: Extract the earliest weight on each date
                   for each participant  
                                                       */
/*******************************************************/

data firstweightperday;
   set sortdata;
   by studyid Local_Date;
   retain measureDate firstWeight;                
   if FIRST.Local_Date then 
      do;
         measureDate = Local_Date; 
         firstWeight = Weight; 
         output;
      end;
   format measureDate mmddyy10.;
run;


/*******************************************************/
/*     
       Q8: Clean Data Set  
                                                       */
/*******************************************************/

data q8_df;
   set firstweightperday;
run;

/*********************************************/
/* 
          Q10: For each participant 
  First date / Last date / Number of days  
                                             */
/*********************************************/

data countdata;
   set q8_df;
   by studyid;
   retain startDate startWeight countofDays;                
   if FIRST.studyid then 
      do;
         startDate = Local_Date; 
         startWeight = Weight; 
         countofDays = 1;
      end;
      else countofDays = countofDays + 1;
      
   if LAST.studyid then 
      do;
         endDate = Local_Date; 
         endWeight = Weight;
         elapsedDays = intck('day', startDate, endDate) + 1; /* elapsed time (in days) */
         weightLoss = startWeight - endWeight;           /* weight loss */
         /* Positive differences indicate weight losses and negative differences indicate weight gains; */
         proportionDays = countofDays/365;
         proportionWeeks = countofDays/52;
         output;                                         /* output only the last record in each group */
      end;
   format startDate mmddyy10. endDate mmddyy10.;
run;

/* Select variables we are interested */
proc sql;
    create table q10_df as 
       select studyid, startDate, endDate, startWeight, endWeight, elapsedDays,
              countofDays, proportionDays, proportionWeeks, weightLoss
              from countdata;
run;


/*********************************************/
/* 
          Q11: Four Periods and Proportion   
                                             */
/*********************************************/

data temp3;
set q8_df;
weeks8_enddate = firstdate + 55;
weeks16_enddate = firstdate + 111;
weeks32_enddate = firstdate + 223;
weeks52_enddate = firstdate + 364;
by studyid;
format weeks8_enddate weeks16_enddate weeks32_enddate weeks52_enddate mmddyy10.;
if measureDate le weeks8_enddate then period_indx = 1;
else if measureDate gt weeks8_enddate and measureDate le weeks16_enddate then period_indx = 2;
else if measureDate gt weeks16_enddate and measureDate le weeks32_enddate then period_indx = 3;
else period_indx = 4;
run;

data want1;
   set temp3;
   where period_indx = 1;
   by studyid;
   retain startDate_period1 startWeight_period1 counts_period1;  

      if FIRST.studyid then 
         do;
            startDate_period1 = Local_Date; 
            startWeight_period1 = Weight; 
            counts_period1 = 1;
         end;
         else counts_period1 = counts_period1 + 1;
         
      if LAST.studyid then 
         do;
            endDate_period1 = Local_Date; 
            endWeight_period1 = Weight;
            weightLoss_period1 = startWeight_period1 - endWeight_period1;           /* weight loss */
            proportionDays_period1 = counts_period1/56;
            proportionWeeks_period1 = counts_period1/8;
            output;                                         /* output only the last record in each group */
         end;
      format startDate_period1 mmddyy10. endDate_period1 mmddyy10.;
      drop period_indx; 
run;
   
data want2;
   set temp3;
   where period_indx = 2;
   by studyid;
   retain startDate_period2 startWeight_period2 counts_period2;  

      if FIRST.studyid then 
         do;
            startDate_period2 = Local_Date; 
            startWeight_period2 = Weight; 
            counts_period2 = 1;
         end;
         else counts_period2 = counts_period2 + 1;
         
      if LAST.studyid then 
         do;
            endDate_period2 = Local_Date; 
            endWeight_period2 = Weight;
            weightLoss_period2 = startWeight_period2 - endWeight_period2;           /* weight loss */
            proportionDays_period2 = counts_period2/56;
            proportionWeeks_period2 = counts_period2/8;
            output;                                         /* output only the last record in each group */
         end;
      format startDate_period2 mmddyy10. endDate_period2 mmddyy10.;
      drop period_indx; 
run;

data want3;
   set temp3;
   where period_indx = 3;
   by studyid;
   retain startDate_period3 startWeight_period3 counts_period3; 

      if FIRST.studyid then 
         do;
            startDate_period3 = Local_Date; 
            startWeight_period3 = Weight; 
            counts_period3 = 1;
         end;
         else counts_period3 = counts_period3 + 1;
            
      if LAST.studyid then 
         do;
            endDate_period3 = Local_Date; 
            endWeight_period3 = Weight;
            weightLoss_period3 = startWeight_period3 - endWeight_period3;           /* weight loss */
            proportionDays_period3 = counts_period3/112;
            proportionWeeks_period3 = counts_period3/16;
            output;                                         /* output only the last record in each group */
         end;
      format startDate_period3 mmddyy10. endDate_period3 mmddyy10.;
      drop period_indx; 
run;

data want4;
   set temp3;
   where period_indx = 4;
   by studyid;
   retain startDate_period4 startWeight_period4 counts_period4; 

      if FIRST.studyid then 
         do;
            startDate_period4 = Local_Date; 
            startWeight_period4 = Weight; 
            counts_period4 = 1;
         end;
         else counts_period4 = counts_period4 + 1;
            
      if LAST.studyid then 
         do;
            endDate_period4 = Local_Date; 
            endWeight_period4 = Weight;
            weightLoss_period4 = startWeight_period4 - endWeight_period4;           /* weight loss */
            proportionDays_period4 = counts_period4/141;
            proportionWeeks_period4 = counts_period4/20;
            output;                                         /* output only the last record in each group */
         end;
      format startDate_period4 mmddyy10. endDate_period4 mmddyy10.;
      drop period_indx; 
run;


proc sql;
   create table wantall as 
      select * from want1 a left join want2 b on a.studyid = b.studyid
         left join want3 c on a.studyid = c.studyid
         left join want4 d on a.studyid = d.studyid;
quit;

proc sql;
   create table q11_df as 
      select distinct studyid, firstdate, weeks8_enddate, 
                      startWeight_period1, endWeight_period1,
                      weightLoss_period1, counts_period1,
                      proportionDays_period1, proportionWeeks_period1,  
                      weeks16_enddate, 
                      startWeight_period2, endWeight_period2,
                      weightLoss_period2, counts_period2,
                      proportionDays_period2, proportionWeeks_period2,  
                      weeks32_enddate,
                      startWeight_period3, endWeight_period3,
                      weightLoss_period3, counts_period3,
                      proportionDays_period3, proportionWeeks_period3,  
                      weeks52_enddate,
                      startWeight_period4, endWeight_period4,
                      weightLoss_period4, counts_period4,
                      proportionDays_period4, proportionWeeks_period4
      from wantall;
quit;

/* data body100.q8_df; */
/* set work.q8_df; */
/* run; */
/*   */
/* data body100.q10_df; */
/* set work.q10_df; */
/* run; */
/*  */
/* data body100.q11_df; */
/* set work.q11_df; */
/* run; */


/*********************************************/
/* 
          Q12: Merge with fq_weightb12    
                                             */
/*********************************************/

data b12;
   set body100.fq_weightb12(encoding = 'asciiany');
run;

proc sql;
   create table q12 as 
      select * from body100.q10_df a left join b12 b on a.studyid = b.studyid
        left join body100.q11_df c on a.studyid = c.studyid;
quit;



/* how many times of weighting per day */
/* less than 1 = 1 */
/* greater than 1 & less than and equal to 2 = 2 */
/* greater than 2 & less than and equal to 3 = 3 */
/* greater than 3 & less than and equal to 4 = 4 */
/* greater than 4 & less than and equal to 5 = 5 */
/* greater than 5 & less than and equal to 6 = 6 */
/* greater than 6 = 7 */

data q13;
set q12;
by studyid;
/* format weeks8_enddate weeks16_enddate weeks32_enddate weeks52_enddate mmddyy10.; */
if proportionweeks le 1 then tpweek_indx = 1;
else if proportionweeks gt 1 and proportionweeks le 2 then tpweek_indx = 2;
else if proportionweeks gt 2 and proportionweeks le 3 then tpweek_indx = 3;
else if proportionweeks gt 3 and proportionweeks le 4 then tpweek_indx = 4;
else if proportionweeks gt 4 and proportionweeks le 5 then tpweek_indx = 5;
else if proportionweeks gt 5 and proportionweeks le 6 then tpweek_indx = 6;
else tpweek_indx = 7;
run;


proc glm data = q13;
   class trt tpweek_indx(ref="1");
   model weightdiff_b12 = trt bvweight tpweek_indx / solution;
run;

proc glm data = q13;
   class tpweek_indx(ref="1");
   model weightdiff_b12 = bvweight tpweek_indx / solution;
run;

proc glm data = q13;
   class trt tpweek_indx;
   model weightdiff_b12 = trt bvweight tpweek_indx trt*tpweek_indx / solution;
run;


data want;
set body100.q13;
where missingweight12 = 0;
run;

/* 297 observations in total, 29 observations didn't have weightdiff_b12 data,  */
/* so 268 observations in data want; */

/* Now let's give 0 instead of missing value to the counts of days for these 4 periods; */
/* (1) No missing value in the 1st period; */
/* (2) 6 missing value in the 2nd period; */
/* (3) 16 missing value in the 3rd period; */
/* (4) 24 missing value in the 4th period; */

data missingtozero;
	set want;
	counts_period2 = coalesce(counts_period2,0);
	proportionDays_period2 = coalesce(proportionDays_period2,0);
	proportionWeeks_period2 = coalesce(proportionWeeks_period2,0);
	counts_period3 = coalesce(counts_period3,0);
	proportionDays_period3 = coalesce(proportionDays_period3,0);
	proportionWeeks_period3 = coalesce(proportionWeeks_period3,0);	
	counts_period4 = coalesce(counts_period4,0);
	proportionDays_period4 = coalesce(proportionDays_period4,0);
	proportionWeeks_period4 = coalesce(proportionWeeks_period4,0);
run;

/* overall mean & ste, mean & ste for each period; */

/* (1) overall; */
proc means data = missingtozero;
    var proportionWeeks_period1 proportionWeeks_period2 proportionWeeks_period3 proportionWeeks_period4;
run;
