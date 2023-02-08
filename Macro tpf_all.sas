/*************************************************/
/* Ning Sun 2022-07-14                           */
/* Macro to run Dr. Kocak's macro for all studyid*/
/*************************************************/

*option symbolgen;
%macro TPF(data=, tvar=, yvar=, wsize=7, mgroup=dtype, mtype=1, aweight=10,
modelchoice=tt|tt, lowerbnd=100, upperbnd=300, predband=11, trueprofile=,
outname=mydata);
options nonotes;
proc format;
value profile 0='Actual Data' 1='Correct Profile' 2='Incorrect Profile' 9='Unknown';
run;
proc sort data=&data; by &tvar; run;
data indata0; set &data;
if &mgroup=&mtype; run; data indata1; set &data;
if &mgroup^=&mtype; timid=_n_; run;
data indata; set indata0 indata1;
%if &trueprofile=%str() %then %do; true_profile=9;
if &mgroup=&mtype then true_profile=0; %end;
%else %do; true_profile=&trueprofile; %end;
run;
proc sql; drop table indata0, indata1; quit;
proc sql noprint; select distinct count(*) into :nofrecords
from indata where timid^=.; quit;
proc sql noprint; select distinct floor(count(*)/&wsize) into :binsize
from indata where timid^=.; quit;
data indata; set indata; recid=_n_; yy=&yvar; tt=&tvar;
if &mgroup=&mtype then do; cweight=&aweight; finalprofile=0; end;
else if yy<=&lowerbnd or yy>=&upperbnd then do; cweight=0; finalprofile=3; end;
else if timid>1 and timid<=&wsize then do; cweight=1; finalprofile=1; end;
if finalprofile in (0 1) then include=1; run;
proc glm data=indata plots=none noprint; where include=1; weight cweight; model
yy=&modelchoice; output out=preddata p=predicted; run;
proc sql; create table dataupdate as select distinct recid, predicted
from preddata order by recid; quit;
data indata; merge indata dataupdate; by recid;
if include=1 and finalprofile not in (0 3) then do;
resid=round(abs(yy-predicted),0.1);
if resid>0 and resid<=&predband then do; finalprofile=1; cweight=1; end;
else if resid>&predband then do; finalprofile=2; cweight=0; end;
end; run;
data indata; set indata; drop predicted resid; run;
proc sql; drop table preddata, dataupdate; quit;
%do i=1 %to &binsize;
data indata; set indata;
if finalprofile in (0 1) or (timid>=%sysevalf(&i*&wsize-&wsize) and
timid<=%sysevalf(&i*&wsize+&wsize)) then include=1;
%if %sysevalf(&binsize+0)=%sysevalf(&i+0) %then %do; include=1; %end; run;
proc glm data=indata plots=none noprint; where include=1; weight cweight; model
yy=&modelchoice; output out=preddata p=predicted; run;
proc sql; create table dataupdate as select distinct recid, predicted
from preddata order by recid; quit;
data indata; merge indata dataupdate; by recid;
if include=1 and finalprofile not in (0 3) then do;
resid=round(abs(yy-predicted),0.1);
if resid>0 and resid<=&predband then do; finalprofile=1; cweight=1; end;
else if resid>&predband then do; finalprofile=2; cweight=0; end;
end; run;
data indata; set indata; drop predicted resid; run;
proc sql; drop table preddata, dataupdate; quit;
%end;
options notes;
proc sql; create table &outname as select distinct studyid, recid, true_profile, &mgroup, tt
as &tvar, yy as &yvar, finalprofile from indata; quit;
proc sql; drop table indata; quit;
proc tabulate data=&outname; class true_profile finalprofile;
label true_profile='Correct Profiles' finalprofile='Predicted Profiles';
table true_profile, finalprofile*n=''; format true_profile finalprofile profile.;
run;
%mend TPF;



%macro tpf_all(data=, predband=, wsize=); 
*%include '/home/u25380825/My Folder/Body trace/Code/kocak macro.sas';
proc sql noprint; 
select distinct count(*) into :n from 
	(select distinct studyid from &data); 
quit;

%let n=%sysevalf(&n+0);

proc sql noprint; 
select distinct studyid	into :id1-:id&n from &data
	order by studyid; 
quit;

%do x=1 %to &n;
  data tempdata&x;
  set &data;
  if studyid=&&&id&x;
  dtype = 0;
  run;

  %tpf(data=tempdata&x, tvar=num_days, yvar=weight, wsize=&wsize, mgroup=dtype, mtype=1, modelchoice=tt, lowerbnd=40, 
  upperbnd=200, predband=&predband, outname=sampledata_profile&x); 
  
  title "ID %upcase(&&&id&x) ";
  proc sgplot data=sampledata_profile&x;
       scatter x=num_days y=weight / group = finalprofile 
                                     name="points"
                                     legendLabel="Weights";
  run;
  
%end;
%mend;



