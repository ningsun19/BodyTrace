/************************************************        */
/* Ning Sun 2023-07-14                                   */
/* Macro to run Dr. Kocak's macro AND GAM for all studyid*/
/*********************************************************/

*option symbolgen;

* Data should have at least 4 columns in long formate: ID, time, weight, data type;
* Clinical weight measured at lab have dtype = 1 and scale measured has dtype = 0;
* WSIZE: Window Size. This is the size of the moving window detecting new 'correct
  profile' measurements and it starts from the first observation;
* PREDBAND: The prediction band around the model prediction beyond which all measurements 
  will be considered not belonging to the correct profile. Default to 8;
* MGROUP: Measurement Group. This variable identifies a given measurement as 'clinic'
  or 'data stream' measurement. This is critical to identify as these two measurement types 
  will be weighed differently in the correct-profile detection process. 
  If you don't have any clinic data, then you still need to create an MGROUP variable and 
  assign the value of 0 to all measurements indicating no clinic measurement;
* MTYPE: The code for the 'clinic' measurements in MGROUP variable. Default is 1;
* AWEIGHT: The weight of the actual 'clinic' measurements. Default is 10;
* MODELCHOICE: The choice of the polynomial model. The variable TT will be created
  during the operation so you simply specify the model using variable TT;
* LOWERBND: The lower bound of measurements below which all measurements are
  considered not belonging to the correct profile without modeling;
* UPPERBND: The upper bound of measurements above which all measurements are considered not 
  belonging to the correct profile without modeling;
* TRUEPROFILE:The variable indicating true profile if available. If not, a new code will be added;
* OUTNAME: The output dataset name to retain the original data as well as the final profile calls in a variable called FINALPROFILE;

%macro BodyTraceClean(data=, predband=8, wsize= 15, tvar=num_days, yvar=weight, mgroup=dtype, mtype=1, aweight=10, modelchoice=tt, lowerbnd=40, upperbnd=200, trueprofile = , outname=sampledata_profile&x); 

options nonotes;

proc format;
value profile 0='Actual Data' 1='Correct Profile' 2='Incorrect Profile' 9='Unknown';
run;

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
  run;


  proc sort data=tempdata&x; by &tvar; run;
  data indata0; set tempdata&x;
  if &mgroup=&mtype; run; 
  data indata1; set tempdata&x;
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
  
  proc sql; create table &outname as select distinct studyid, recid, true_profile, &mgroup, tt
  as &tvar, yy as &yvar, finalprofile from indata; quit;
  proc sql; drop table indata; quit;
  proc tabulate data=&outname; class true_profile finalprofile;
  label true_profile='Correct Profiles' finalprofile='Predicted Profiles';
  table true_profile, finalprofile*n=''; format true_profile finalprofile profile.;
  run;


  title "ID %upcase(&&&id&x) ";
  proc sgplot data=sampledata_profile&x;
       scatter x=&tvar y=&yvar / group = finalprofile 
                                     name="points"
                                     legendLabel="Weights";
  run;
  
  title h=2 "ID-&&&id&x";
  ods exclude all;
  proc gam data=&outname;
  where finalprofile=1 ;
  model weight = loess(&tvar)/method=gcv;
	output out=out&x pred resid;
  run;
  ods exclude none;
	
  data out&x;
  set out&x;
  outlier_idx = 0;
  if r_weight >2.27 or r_weight < -2.27 then outlier_idx = 1;
  run;

  proc sgplot data=out&x; 
      scatter x=&tvar y=&yvar / name="points" legendLabel="Weights" colorresponse=outlier_idx; 
      series  x=&tvar y=p_&yvar / name="line" legendLabel="Predicted weights" lineattrs = GRAPHFIT; 
      discretelegend "points" "line"; 
  run; 
  
  title; 	 
%end;
%mend;
