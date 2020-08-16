% show the ROI which spe by PixelsInObj only
% we hightlight the ROI
%  -Obj: the whole image region
%  -PixelsInObj: pixel indext list you want to show
%  -contrast: the contrast bettween roi want to show and the original im
% the outputShownIM is the image you see
function ShownIM=LshowOnlyObj(Obj,PixelsInObj,contrast,figNo)
if size(Obj,3)==3
    Obj_R=Obj(:,:,1);
    Obj_G=Obj(:,:,2);
    Obj_B=Obj(:,:,3);
    Need2Show = false(size(Obj_R));
    Need2Show(PixelsInObj) = true;
    
    
    Obj_R_temp=Obj_R;
    Obj_R_temp(~Need2Show)=Obj_R_temp(~Need2Show)/contrast;
    Obj_G_temp=Obj_G;
    Obj_G_temp(~Need2Show)=Obj_G_temp(~Need2Show)/contrast;
    Obj_B_temp=Obj_B;
    Obj_B_temp(~Need2Show)=Obj_B_temp(~Need2Show)/contrast;
    
    Obj_show=cat(3,Obj_R_temp,Obj_G_temp,Obj_B_temp);
else
    Obj_temp=Obj;
    Need2Show = false(size(Obj));
    Need2Show(PixelsInObj) = true;
    Obj_temp(~Need2Show)=Obj_temp(~Need2Show)/contrast;
    Obj_show=Obj_temp;
end
% Obj_show(:,:,1)=Obj_R_temp;
% Obj_show(:,:,2)=Obj_G_temp;
% Obj_show(:,:,3)=Obj_B_temp;
if nargin>3
    show(Obj_show,figNo);
else
    show(Obj_show);
end
ShownIM=Obj_show;
end