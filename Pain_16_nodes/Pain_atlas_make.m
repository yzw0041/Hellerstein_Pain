
%clear all
% 10/25/2017
% written by yun wang
% this code can create an atlas with different label. 
function V=roi_atlas_label(filename)
        clc
        s=spm_select;
        M=zeros(91,109,91);
        for i=1:size(s,1)
            a = spm_vol(s(i,:));
            b = spm_read_vols(a);
             b=floor(b);
            disp(unique(b)');

            b(b>0)=i;
            M=M+b;
        end
         %remove pinfo field 
         M=ceil(M);
        a=rmfield(a,'pinfo');

        A=a;
        A.fname=filename;
        V=spm_write_vol(A,M);
        disp(unique(M)');
        
end
