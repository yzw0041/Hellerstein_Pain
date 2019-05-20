libname pain 'P:/Users/Seonjoo/posner/yun_paper_revision_20180621/analysis';


proc import out=pain DATAFILE="P:/Users/Seonjoo/posner/yun_paper_revision_20180621/data/Mediation_All_update_20180802.sav"
  DBMS=SAV REPLACE;
RUN;


data pain.pain;
set pain (rename=(T1=pain_T1 T2=pain_T2));
pain_change=pain_T1-pain_T2;
pain_change2=pain_T2-pain_T1;
A=treat;
M=pain_change;
Y=depress;
C1=pain_T1-0.1492133;
C2=depress_T1-37.3906250;
C3=Age-37.3906250;
C4=Sex;*-0.5625;
C5=Study;
ID=_N_;
label Depress='Depression change (T1-T2)';
label  Pain='Pain Network Density Change (T1-T2)';
label pain_change='Pain Network Density Change (T1-T2)'; 
run;

proc sort data=pain.pain;by ID Study Age Sex treat;run;
proc transpose data=pain.pain out=long(rename=(col1=pain _LABEL_=time));
var pain_T1 pain_T2;by ID Study Age Sex treat;run;
proc sort data=long;by study id;run;
/*ods html;
proc mixed data=long;class sex time treat;
model pain=time*treat sex age/solution;
random intercept/subject=id;
by study;
run;
proc sort data=pain.pain;by study;run;
proc glm data=pain.pain;class sex treat;
      model pain_T1 pain_T2 = treat sex age/nouni effectsize;
      repeated Time;
by study;
run;
proc glm data=Old;
      class Group Subject Time;
      model y=Group Subject(Group) Time Group*Time;
      test h=Group e=Subject(Group);
   run;*/


%macro fourway_modmed(dataset=pain.pain,
	covparams=tc3=0 tc4=0  bc3=0 bc4=0, 
	covinitial=cc3=0;cc4=0;, 
	definebcc=bcc = bc3*cc3 + bc4*cc4;,
	covstatement_y= + tc3*C3 + tc4*C4,
	covstatement_m= + bc3*C3 + bc4*C4,
	where=);
proc nlmixed data=&dataset; 
parms t0=0 t1=0 t2=0 t3=0 b0=0.000 b1=0 ss_m=1 ss_y=1 &covparams ; 
a1=1; a0=0; 
mstar=0; 
&covinitial 
mu_y=t0 + t1*A + t2*M + t3*A*M &covstatement_y; 
mu_m =b0 + b1*A &covstatement_m; 
ll_y= -((y-mu_y)**2)/(2*ss_y)-0.5*log(ss_y); 
ll_m= -((m-mu_m)**2)/(2*ss_m)-0.5*log(ss_m); 
ll_o= ll_m + ll_y; 
model Y ~general(ll_o); 
&definebcc 
cde = (t1 + t3*mstar)*(a1-a0); 
intref = t3*(b0 + b1*a0 + bcc - mstar)*(a1-a0); 
intmed = t3*b1*(a1-a0)*(a1-a0); pie = (t2*b1 + t3*b1*a0)*(a1-a0); te = cde + intref + intmed + pie; 
estimate 'Total Effect' te; estimate 'CDE' cde; estimate 'INTref' intref; estimate 'INTmed' intmed; estimate 'PIE' pie;
estimate 'Proportion CDE' cde/te; 
estimate 'Proportion INTref' intref/te; 
estimate 'Proportion INTmed' intmed/te; 
estimate 'Proportion PIE' pie/te; 
estimate 'Overall Proportion Mediated' (pie+intmed)/te; 
estimate 'Overall Proportion Attributable to Interaction' (intref+intmed)/te; 
estimate 'Overall Proportion Eliminated' (intref+intmed+pie)/te; 
&where
run;
%mend fourway_modmed;
 

ods _all_ close;
ods tagsets.ExcelXP path='C:\Users\leeseon\Documents' file='fourway_decomposition_submission_20180803.xml' style=statistical;

ods tagsets.ExcelXP options(sheet_name='Age_Sex_adjusted' EMBEDDED_TITLES='yes'  auto_subtotals='yes' sheet_interval='none' autofilter='all' autofilter_table='2');

title1 'With Covariates:  Age and Sex only';
title1 'Study1 Only';
ods select AdditionalEstimates;

%fourway_modmed(where=where study=1; );

title1 'Study2 Only';ods select AdditionalEstimates;
%fourway_modmed(where=where study=2; );

title1 'Two Studies Combined';ods select AdditionalEstimates;
%fourway_modmed();

ods tagsets.ExcelXP options(sheet_name='Age_Sex_Baseline_adjusted' EMBEDDED_TITLES='yes' auto_subtotals='yes' sheet_interval='none' autofilter='all' autofilter_table='2');

title1 'With Covariates:  Age and Sex, and baseline mediator and depression';
title1 'Study1 Only';ods select AdditionalEstimates;
%fourway_modmed(covparams=tc1=0 tc2=0 tc3=0 tc4=0 bc1=0 bc2=0 bc3=0 bc4=0, 
	covinitial=cc1=0;cc2=0;cc3=0;cc4=0;, 
	covstatement_y= + tc1*C1 + tc2*C2 + tc3*C3 + tc4*C4,
	covstatement_m= + bc1*C1 + bc2*C2 + bc3*C3 + bc4*C4,
	definebcc=bcc = bc1*cc1 + bc2*cc2 + bc3*cc3 + bc4*cc4;,where=where study=1; );
title1 'Study2 Only';ods select AdditionalEstimates;
%fourway_modmed(covparams=tc1=0 tc2=0 tc3=0 tc4=0 bc1=0 bc2=0 bc3=0 bc4=0, 
	covinitial=cc1=0;cc2=0;cc3=0;cc4=0;, 
	covstatement_y= + tc1*C1 + tc2*C2 + tc3*C3 + tc4*C4,
	covstatement_m= + bc1*C1 + bc2*C2 + bc3*C3 + bc4*C4,
	definebcc=bcc = bc1*cc1 + bc2*cc2 + bc3*cc3 + bc4*cc4;,where=where study=2; );
title1 'Two Studies Combined';ods select AdditionalEstimates;
%fourway_modmed(covparams=tc1=0 tc2=0 tc3=0 tc4=0 bc1=0 bc2=0 bc3=0 bc4=0, 
	covinitial=cc1=0;cc2=0;cc3=0;cc4=0;, 
	covstatement_y= + tc1*C1 + tc2*C2 + tc3*C3 + tc4*C4,
	covstatement_m= + bc1*C1 + bc2*C2 + bc3*C3 + bc4*C4,
	definebcc=bcc = bc1*cc1 + bc2*cc2 + bc3*cc3 + bc4*cc4; );


title1 'With Covariates:  Study, Age and Sex, and baseline mediator and depression';
title1 'Study1 Only';ods select AdditionalEstimates;
%fourway_modmed(covparams=tc1=0 tc2=0 tc3=0 tc4=0 bc1=0 bc2=0 bc3=0 bc4=0, 
	covinitial=cc1=0;cc2=0;cc3=0;cc4=0;, 
	covstatement_y= + tc1*C1 + tc2*C2 + tc3*C3 + tc4*C4,
	covstatement_m= + bc1*C1 + bc2*C2 + bc3*C3 + bc4*C4,
	definebcc=bcc = bc1*cc1 + bc2*cc2 + bc3*cc3 + bc4*cc4;,where=where study=1; );
title1 'Study2 Only';ods select AdditionalEstimates;
%fourway_modmed(covparams=tc1=0 tc2=0 tc3=0 tc4=0 bc1=0 bc2=0 bc3=0 bc4=0, 
	covinitial=cc1=0;cc2=0;cc3=0;cc4=0;, 
	covstatement_y= + tc1*C1 + tc2*C2 + tc3*C3 + tc4*C4,
	covstatement_m= + bc1*C1 + bc2*C2 + bc3*C3 + bc4*C4,
	definebcc=bcc = bc1*cc1 + bc2*cc2 + bc3*cc3 + bc4*cc4;,where=where study=2; );
title1 'Two Studies Combined';ods select AdditionalEstimates;
%fourway_modmed(covparams=tc1=0 tc2=0 tc3=0 tc4=0 bc1=0 bc2=0 bc3=0 bc4=0, 
	covinitial=cc1=0;cc2=0;cc3=0;cc4=0;, 
	covstatement_y= + tc1*C1 + tc2*C2 + tc3*C3 + tc4*C4,
	covstatement_m= + bc1*C1 + bc2*C2 + bc3*C3 + bc4*C4,
	definebcc=bcc = bc1*cc1 + bc2*cc2 + bc3*cc3 + bc4*cc4; );



ods tagsets.ExcelXP options(sheet_name='Swiching mediator and outcome' EMBEDDED_TITLES='yes'  auto_subtotals='yes' sheet_interval='none' autofilter='all' autofilter_table='2');


data pain2;
set pain.pain;
A=treat;
Y=pain_change;
M=depress;
C1=pain_T1-0.1492133;
C2=depress_T1-37.3906250;
C3=Age-37.3906250;
C4=Sex;*-0.5625;
C5=Study;
ID=_N_;
run;
title1 'Treat -> Depress -> Pain';
title1 'With Covariates:  Age and Sex only';
title1 'Study1 Only';
ods select AdditionalEstimates;

%fourway_modmed(dataset=pain2,where=where study=1; );

title1 'Study2 Only';ods select AdditionalEstimates;
%fourway_modmed(dataset=pain2,where=where study=2; );

title1 'Two Studies Combined';ods select AdditionalEstimates;
%fourway_modmed(dataset=pain2);

title1 'With Covariates:  Age and Sex, and baseline mediator and depression';
title1 'Study1 Only';ods select AdditionalEstimates;
%fourway_modmed(dataset=pain2,covparams=tc1=0 tc2=0 tc3=0 tc4=0 bc1=0 bc2=0 bc3=0 bc4=0, 
	covinitial=cc1=0;cc2=0;cc3=0;cc4=0;, 
	covstatement_y= + tc1*C1 + tc2*C2 + tc3*C3 + tc4*C4,
	covstatement_m= + bc1*C1 + bc2*C2 + bc3*C3 + bc4*C4,
	definebcc=bcc = bc1*cc1 + bc2*cc2 + bc3*cc3 + bc4*cc4;,where=where study=1; );
title1 'Study2 Only';ods select AdditionalEstimates;
%fourway_modmed(dataset=pain2,covparams=tc1=0 tc2=0 tc3=0 tc4=0 bc1=0 bc2=0 bc3=0 bc4=0, 
	covinitial=cc1=0;cc2=0;cc3=0;cc4=0;, 
	covstatement_y= + tc1*C1 + tc2*C2 + tc3*C3 + tc4*C4,
	covstatement_m= + bc1*C1 + bc2*C2 + bc3*C3 + bc4*C4,
	definebcc=bcc = bc1*cc1 + bc2*cc2 + bc3*cc3 + bc4*cc4;,where=where study=2; );
title1 'Two Studies Combined';ods select AdditionalEstimates;
%fourway_modmed(dataset=pain2,covparams=tc1=0 tc2=0 tc3=0 tc4=0 bc1=0 bc2=0 bc3=0 bc4=0, 
	covinitial=cc1=0;cc2=0;cc3=0;cc4=0;, 
	covstatement_y= + tc1*C1 + tc2*C2 + tc3*C3 + tc4*C4,
	covstatement_m= + bc1*C1 + bc2*C2 + bc3*C3 + bc4*C4,
	definebcc=bcc = bc1*cc1 + bc2*cc2 + bc3*cc3 + bc4*cc4; );


title1 'With Covariates:  Study, Age and Sex, and baseline mediator and depression';
title1 'Study1 Only';ods select AdditionalEstimates;
%fourway_modmed(dataset=pain2,covparams=tc1=0 tc2=0 tc3=0 tc4=0 bc1=0 bc2=0 bc3=0 bc4=0, 
	covinitial=cc1=0;cc2=0;cc3=0;cc4=0;, 
	covstatement_y= + tc1*C1 + tc2*C2 + tc3*C3 + tc4*C4,
	covstatement_m= + bc1*C1 + bc2*C2 + bc3*C3 + bc4*C4,
	definebcc=bcc = bc1*cc1 + bc2*cc2 + bc3*cc3 + bc4*cc4;,where=where study=1; );
title1 'Study2 Only';ods select AdditionalEstimates;
%fourway_modmed(dataset=pain2,covparams=tc1=0 tc2=0 tc3=0 tc4=0 bc1=0 bc2=0 bc3=0 bc4=0, 
	covinitial=cc1=0;cc2=0;cc3=0;cc4=0;, 
	covstatement_y= + tc1*C1 + tc2*C2 + tc3*C3 + tc4*C4,
	covstatement_m= + bc1*C1 + bc2*C2 + bc3*C3 + bc4*C4,
	definebcc=bcc = bc1*cc1 + bc2*cc2 + bc3*cc3 + bc4*cc4;,where=where study=2; );
title1 'Two Studies Combined';ods select AdditionalEstimates;
%fourway_modmed(dataset=pain2,covparams=tc1=0 tc2=0 tc3=0 tc4=0 bc1=0 bc2=0 bc3=0 bc4=0, 
	covinitial=cc1=0;cc2=0;cc3=0;cc4=0;, 
	covstatement_y= + tc1*C1 + tc2*C2 + tc3*C3 + tc4*C4,
	covstatement_m= + bc1*C1 + bc2*C2 + bc3*C3 + bc4*C4,
	definebcc=bcc = bc1*cc1 + bc2*cc2 + bc3*cc3 + bc4*cc4; );


ods tagsets.ExcelXP close;
ods html;
