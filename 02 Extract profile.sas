/* Generated Code (IMPORT) */
/* Source File: Bodytrace ID group.xlsx */
/* Source Path: /home/u25380825/My Folder/Body trace */
/* Code generated on: 7/27/22, 9:41 PM */
/* UPDATED 08/15/22 */ 
**********************;


FILENAME REFFILE '/home/u25380825/My Folder/Body trace/Bodytrace ID group.xlsx';

PROC IMPORT DATAFILE=REFFILE
	DBMS=XLSX
	OUT=WORK.IMPORT;
	GETNAMES=YES;
	SHEET="Sheet2";
RUN;

**********************;
proc sql;
create table p8w20 as 
select * from body100.localdatetime_365
where studyid in (select p8_w20 from work.import);
quit;

%BodyTraceClean(data = p8w20, predband=8, wsize=20);

data body100.classification_8_20;
set sampledata_profile1-sampledata_profile203;
run;

***********************************************;

proc sql;
create table p8w5 as 
select * from body100.localdatetime_365
where studyid in (select p8_w5 from work.import);
quit;

%BodyTraceClean(data = p8w5, predband=8, wsize=5);

data body100.classification_8_5;
set sampledata_profile1-sampledata_profile34;
run;

******************;

proc sql;
create table p5w10 as 
select * from body100.localdatetime_365
where studyid in (select p5_w10 from work.import);
quit;

%BodyTraceClean(data = p5w10, predband=5, wsize=10);

data body100.classification_5_10;
set sampledata_profile1-sampledata_profile26;
run;

**********************;

proc sql;
create table p5w5 as 
select * from body100.localdatetime_365
where studyid in (select p5_w5 from work.import);
quit;

%BodyTraceClean(data = p5w5, predband=5, wsize=5);

data body100.classification_5_5;
set sampledata_profile1-sampledata_profile3;
run;

*********************;

proc sql;
create table p10w5 as 
select * from body100.localdatetime_365
where studyid in (select p10_w5 from work.import);
quit;

%BodyTraceClean(data = p10w5, predband=10, wsize=5);

data body100.classification_10_5;
set sampledata_profile1-sampledata_profile3;
run;


*********************;

proc sql;
create table p10w10 as 
select * from body100.localdatetime_365
where studyid in (select p10_w10 from work.import);
quit;

%BodyTraceClean(data = p10w10, predband=10, wsize=10);

data body100.classification_10_10;
set sampledata_profile1-sampledata_profile6;
run;


*********************;

proc sql;
create table p15w10 as 
select * from body100.localdatetime_365
where studyid in (select p15_w10 from work.import);
quit;

%BodyTraceClean(data = p15w10, predband=15, wsize=10);

data body100.classification_15_10;
set sampledata_profile1-sampledata_profile8;
run;


****************;
Cases need special parameters
****************;

data sampledata;
set body100.localdatetime_365;
if studyid = 1225;
run;


%tpf(data=sampledata, tvar=num_days, yvar=weight, wsize=5, mgroup=dtype, mtype=1,
modelchoice=tt, lowerbnd=60, upperbnd=250, predband=8, outname=sampledata_profile1);

proc sgplot data=sampledata_profile1;
       scatter x=num_days y=weight / group = finalprofile 
                                      name="points"
                                      legendLabel="Weights";
run;

****************;
data sampledata;
set body100.localdatetime_365;
if studyid = 1398;
run;


%tpf(data=sampledata, tvar=num_days, yvar=weight, wsize=5, mgroup=dtype, mtype=1,
modelchoice=tt, lowerbnd=40, upperbnd=250, predband=4, outname=sampledata_profile2);

proc sgplot data=sampledata_profile2;
       scatter x=num_days y=weight / group = finalprofile 
                                      name="points"
                                      legendLabel="Weights";
run;

**********;

data sampledata;
set body100.localdatetime_365;
if studyid = 1822;
run;


%tpf(data=sampledata, tvar=num_days, yvar=weight, wsize=10, mgroup=dtype, mtype=1,
modelchoice=tt, lowerbnd=110, upperbnd=250, predband=15, outname=sampledata_profile3);

proc sgplot data=sampledata_profile3;
       scatter x=num_days y=weight / group = finalprofile 
                                      name="points"
                                      legendLabel="Weights";
run;

data sampledata_profile3;
set sampledata_profile3;
if finalprofile = 1 then finalprofile = 0;
if finalprofile = 2 then finalprofile = 1;
run;

**********;

data sampledata;
set body100.localdatetime_365;
if studyid = 1845;
run;


%tpf(data=sampledata, tvar=num_days, yvar=weight, wsize=20, mgroup=dtype, mtype=1,
modelchoice=tt, lowerbnd=75, upperbnd=250, predband=15, outname=sampledata_profile4);

proc sgplot data=sampledata_profile4;
       scatter x=num_days y=weight / group = finalprofile 
                                      name="points"
                                      legendLabel="Weights";
run;

**********;

data sampledata;
set body100.localdatetime_365;
if studyid = 2161;
run;


%tpf(data=sampledata, tvar=num_days, yvar=weight, wsize=10, mgroup=dtype, mtype=1,
modelchoice=tt, lowerbnd=60, upperbnd=250, predband=15, outname=sampledata_profile5);

proc sgplot data=sampledata_profile5;
       scatter x=num_days y=weight / group = finalprofile 
                                      name="points"
                                      legendLabel="Weights";
run;

**************;

data sampledata;
set body100.localdatetime_365;
if studyid = 890;
run;


%tpf(data=sampledata, tvar=num_days, yvar=weight, wsize=20, mgroup=dtype, mtype=1,
modelchoice=tt, lowerbnd=100, upperbnd=250, predband=7, outname=sampledata_profile6);

proc sgplot data=sampledata_profile6;
       scatter x=num_days y=weight / group = finalprofile 
                                      name="points"
                                      legendLabel="Weights";
run;

**************;

data sampledata;
set body100.localdatetime_365;
if studyid = 1792;
run;


%tpf(data=sampledata, tvar=num_days, yvar=weight, wsize=5, mgroup=dtype, mtype=1,
modelchoice=tt, lowerbnd=40, upperbnd=250, predband=20, outname=sampledata_profile7);

proc sgplot data=sampledata_profile7;
       scatter x=num_days y=weight / group = finalprofile 
                                      name="points"
                                      legendLabel="Weights";
run;

**************;

data sampledata;
set body100.localdatetime_365;
if studyid = 102;
run;


%tpf(data=sampledata, tvar=num_days, yvar=weight, wsize=20, mgroup=dtype, mtype=1,
modelchoice=tt, lowerbnd=60, upperbnd=250, predband=10, outname=sampledata_profile8);

proc sgplot data=sampledata_profile8;
       scatter x=num_days y=weight / group = finalprofile 
                                      name="points"
                                      legendLabel="Weights";
run;


**************;

data sampledata;
set body100.localdatetime_365;
if studyid = 1148;
run;


%tpf(data=sampledata, tvar=num_days, yvar=weight, wsize=5, mgroup=dtype, mtype=1,
modelchoice=tt, lowerbnd=40, upperbnd=120, predband=8, outname=sampledata_profile9);

proc sgplot data=sampledata_profile9;
       scatter x=num_days y=weight / group = finalprofile 
                                      name="points"
                                      legendLabel="Weights";
run;

data sampledata_profile9;
set sampledata_profile9;
if finalprofile = 1 then finalprofile = 0;
if finalprofile = 2 then finalprofile = 1;
if weight<60 then finalprofile = 0;
run;

*****;

data sampledata;
set body100.localdatetime_365;
if studyid = 1046;
run;


%tpf(data=sampledata, tvar=num_days, yvar=weight, wsize=5, mgroup=dtype, mtype=1,
modelchoice=tt, lowerbnd=40, upperbnd=250, predband=8, outname=sampledata_profile10);

proc sgplot data=sampledata_profile10;
       scatter x=num_days y=weight / group = finalprofile 
                                      name="points"
                                      legendLabel="Weights";
run;

data sampledata_profile10;
set sampledata_profile10;
if finalprofile = 1 then finalprofile = 0;
if finalprofile = 2 then finalprofile = 1;
run;


**********************************MERGE, SELECT THE CORRECT PROFILE *********;

data body100.classification_merged;
set body100.classification_10_10 body100.classification_10_5 body100.classification_15_10 body100.classification_5_10 
body100.classification_5_5 body100.classification_8_20 body100.classification_8_5 sampledata_profile1-sampledata_profile10;
run;

data body100.correctprofile;
set body100.classification_merged;
if finalprofile=1;
run;

proc sql;
select count(*) as n from
(select distinct studyid from body100.correctprofile);
quit;

***293 IDS IN DF;

proc sql;
create table cleandf as
select * from body100.localdatetime_365 as a
right join body100.correctprofile as b
on (a.studyid=b.studyid and a.record_id=b.recid);
quit;

data cleandf; set cleandf;
drop recid true_profile dtype finalprofile;
run;


*** OTHER 4 IDS WITHOUT USING MACRO;
data sampledata1;
set body100.localdatetime_365;
if studyid = 233;
if weight>100;
run;

data sampledata2;
set body100.localdatetime_365;
if studyid = 1036;
if num_days<220;
if weight>100;
run;

data sampledata3;
set body100.localdatetime_365;
if studyid = 1177;
if weight>79;
run;

data sampledata4;
set body100.localdatetime_365;
if studyid = 2676;
if num_days<100;
run;


*** MERGE;
data body100.classification_merged2;
set cleandf sampledata1-sampledata4;
run;

proc sql;
select count(*) as n from
(select distinct studyid from body100.classification_merged2);
quit;

/* CLEAN AGAIN FOR GAM MODEL*/
data body100.classification_merged2;
set body100.classification_merged2;
if studyid=2494 then delete;
run;

** for ID 2494;
data sample; set body100.correctprofile;
if studyid=2494;
run;

%tpf(data=sample, tvar=num_days, yvar=weight, wsize=30, mgroup=dtype, mtype=1,
modelchoice=tt, lowerbnd=55, upperbnd=250, predband=3, outname=sampledata_profile);

proc sgplot data=sampledata_profile;
       scatter x=num_days y=weight / group = finalprofile 
                                      name="points"
                                      legendLabel="Weights";
run;

data sampledata_profile;
set sampledata_profile;
drop recid;
run;

data sample;
set sample;
drop finalprofile;
run;

data sampledata_profile;
merge sample sampledata_profile;
run;

data sampledata_profile;
set sampledata_profile;
if finalprofile=1;
run;

proc sql;
create table clean2494 as
select * from body100.localdatetime_365 as a
right join sampledata_profile as b
on (a.studyid=b.studyid and a.record_id=b.recid);
quit;

data clean2494; set clean2494;
drop recid true_profile dtype finalprofile;
run;

data body100.classification_merged2;
set body100.classification_merged2 clean2494;
run;


**************;
%macro gamplot(data=);
proc sql noprint; 
select distinct count(*) into :n from 
	(select distinct studyid from &data); 
quit;

%let n=%sysevalf(&n+0);

proc sql noprint; 
select distinct studyid	into :id1-:id&n from &data
	order by studyid; 
quit;

%do i=1 %to &n;
	title h=2 "Patient-&&&id&i";
	ods exclude all;
	proc gam data=&data;
		where studyid=&&&id&i ;
		model weight = loess(num_days)/method=gcv;
		output out=out&i pred resid;
	run;
	ods exclude none;
	
	data out&i;
	set out&i;
	outlier_idx = 0;
	if r_weight >2.27 or r_weight < -2.27 then outlier_idx = 1;
	run;

 	proc sgplot data=out&i; 
        scatter x=num_days y=weight / name="points" legendLabel="Weights" colorresponse=outlier_idx; 
        series  x=num_days y=p_weight / name="line" legendLabel="Predicted weights" lineattrs = GRAPHFIT; 
        discretelegend "points" "line"; 
 	run; 
  
 	title; 	 
%end;
%mend;

***********;
%gamplot(data=body100.classification_merged2);

data body100.cleandf;
set out1-out297;
run;

/* 55030 obs, 297 ids */

proc sql;
select b.studyid, nout, ncount, sum(nout, ncount) as n, (ncount/sum(nout, ncount)) as prop from 
(select studyid, count(outlier_idx) as nout from body100.cleandf
where outlier_idx = 1
group by studyid) as a
right join
(select studyid, count(outlier_idx) as ncount from body100.cleandf
where outlier_idx = 0
group by studyid) as b
on a.studyid = b.studyid
;
quit;

data body100.cleandf_use;
set body100.cleandf;
if outlier_idx = 0;
run;

/* 53962 obs */

