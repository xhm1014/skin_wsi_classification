%%-----------PhD Project----------%%
% Author: Hongming Xu
% Department of ECE, University of Alberta
% June 29 2016
%%--------THESE PROGRAMS ARE NOT ALLOWED TO BE DISTRIBUTED WITHOUT AUTHOR'S
%%PERMISSION--------------------------%%




%% 0. prepare the file name, load image, ...
clearvars;
close all;
Outputpath='C:\Users\mxu\Desktop\ClassfInterRes\Jun-29-2016\enev\'; %% for saving intermediate results
Outputpath2='C:\Users\mxu\Desktop\ClassfInterRes\Jun-29-2016\dnev\'; %% for saving intermediate results
Outputpath3='C:\Users\mxu\Desktop\ClassfInterRes\Jun-29-2016\features\'; %% for saving intermediate results
AnalysisMagnification=25;                                    %% image magnification
ResAt40X=0.11625*2;                                          %% micrometer/per pixel
ResAtcurAnaMag=ResAt40X*(40/AnalysisMagnification);
load filenameDB_4WSI.mat
Foldername='C:/ConvertedPath/IMsat_1_4/';                    %% the path to store images

index=1;
%% 1. process WSIs
for idx4Set=2:length(filenameDB_Melanoma)    %% melanoma
%for idx4Set=1:length(filenameDB_Neavus)     %% nevus
%for idx4Set=1:length(filenameDB_Normal)     %% normal
    curSet=filenameDB_Melanoma{idx4Set};     %% melanoma
%       curSet=filenameDB_Neavus{idx4Set};       %% nevus
%       curSet=filenameDB_Normal{idx4Set};       %% normal
    
    for j=1:size(curSet,1)
        disp(sprintf('Processing the %dth biospy in %dth set\n',j,idx4Set));
        wholeFilename=[Foldername curSet(j,:)];
        %%% the layout of the image
        Polarity='row-wise';
        AnalysisDirection='BU';% buttom to up
        
        
        %% read image
        IM=imread(wholeFilename);
        sizeI=size(IM);
        
        %% 1.1 IMPyramid
        %BottomLevel=1;
        MidLevel=2;
        TopLevel=3;
        [IMPyramid,IMsizes]=LgetPsudoIMPyramidV2(IM,3,MidLevel);
        clear IM;
        
        %% 2. Seg rough Epi;enlarge the Epi area for pontiential analysis
        %         IM_PyraimdTop=IMPyramid(TopLevel).im;
        %
        %         %         maskEpidermis_PyraimdTop=LSegRoughEpidermisV1(IM_PyraimdTop);
        %         %         LshowObjonlybyLogicalMask(maskEpidermis_PyraimdTop,IM_PyraimdTop,114);
        %
        %         maskEpidermis_PyraimdTop=LSegRoughEpidermis4ToBeEnhanced(IM_PyraimdTop,'R',0);
        %
        %         Para4EnhacedEpiSeg.T_radius=1;
        %         Para4EnhacedEpiSeg.T_size=[4,4];
        %         Para4EnhacedEpiSeg.i=i;
        %         Para4EnhacedEpiSeg.j=j;
        %         Para4EnhacedEpiSeg.savepdf=0;
        %
        %         [maskEpidermis_PyraimdTop_enhanced,PDF]=LSegRoughEpidermis_enhancedV2(IM_PyraimdTop,maskEpidermis_PyraimdTop,'R',Para4EnhacedEpiSeg,0);
        %         epidermis_mask=maskEpidermis_PyraimdTop_enhanced;
        
        %% 1.2 epidermis segmentation based on thickness measurement (proposed by Hongming Xu)
        IM_PyraimdMid=IMPyramid(MidLevel).im;
        IM_PyraimdTop=IMPyramid(TopLevel).im;
        mEpi=md_segCoarseEpidermis(IM_PyraimdMid,'R');                             % coarse segmentaton
        stemp=size(IM_PyraimdTop);
        mEpi=imresize(mEpi,stemp(1:2));
        imagethick=md_thicknessCal(mEpi);                                            % thickness measurement
        [epidermisMaskTop,~]=md_segFineEpidermis(IM_PyraimdTop,imagethick,mEpi);        % fine segmentation
        clear IM_PyraimdMid mEpi stemp;
        %        LshowObjonlybyLogicalMask(epidermisMaskTop,IM_PyraimdTop,115);
        
        %% epidermis segmention evaluation
        %        ev_showBound(IM_PyraimdTop,epidermisMaskTop,'g',1);
        %        blme=bwperim(epidermisMaskTop);
        %        overlay1=imoverlay(IM_PyraimdTop,blme,[0 1 0]);
        
        
        
        %% 1.3 generate regions-of-interest & dermis segmentation
        %        physical_thick=650; % micrometer
        physical_thick=600;          % by micrometer
        thickness=round(physical_thick/ResAtcurAnaMag/4); % by pixels
        roiMaskTop=md_roiMaskGeneration(epidermisMaskTop,thickness,AnalysisDirection);
        dermisMaskTop=md_segDermis(roiMaskTop,IM_PyraimdTop(:,:,1),epidermisMaskTop);    %% dermis segmentation
        %        ev_showBound(IM_PyraimdTop,dermisMaskTop,'g',1);
        %
        [maskfRoi,IMfRoi,efMask,dfMask]=md_cofMaskGeneration(roiMaskTop,IMPyramid(1).im,physical_thick/ResAtcurAnaMag,epidermisMaskTop,dermisMaskTop);
        clear IMPyramid;
        [maskfRot,IMfRot,efmRot,dfmRot]=md_rotImage(maskfRoi,IMfRoi,efMask,dfMask);
        [IMTiles,efmTiles,dfmTiles]=md_getImageTiles(maskfRot,IMfRot,2000,efmRot,dfmRot);
        clear epidermisMaskTop dermisMaskTop roiMaskTop IMfRoi maskfRoi efMask dfMask IMfRot maskfRot efmRot dfmRot;
        
        %         for k=1:length(IMTilesN)
        %             temp=IMTilesN{k};
        %             temp1=temp(:,:,1).*uint8(efmTiles{k});
        %             temp2=temp(:,:,1).*uint8(dfmTiles{k});
        %             s1=num2str(idx4Set);
        %             s2=num2str(j);
        %             s3=num2str(k);
        %             s41='e.tif';
        %             s42='d.tif';
        %             %s43='.tif';
        %             fname=strcat(s1,s2,s3,s41);
        %             fname2=strcat(s1,s2,s3,s42);
        %             %fname3=strcat(s1,s2,s3,s43);
        %             outputfilename=[Outputpath,fname];
        %             outputfilename2=[Outputpath,fname2];
        %             %outputfilename3=[Outputpath,fname3];
        %             imwrite(temp1,outputfilename);
        %             imwrite(temp2,outputfilename2);
        %             %imwrite(temp,outputfilename3);
        %         end
        
        
        %% 1.4 epidermis features contruction
        
        [eIMTiles,eTiles]=md_epiDer(IMTiles,efmTiles,0);  %% obtain epidermis for efficiency
        clear efmTiles;
        
        [MorphoInfo,AllPtsonBnd_Basal,AllPtsonBnd_Keratin]=...
            LgetEpidermisMorphoInfo(eTiles,AnalysisDirection,ResAtcurAnaMag);
        
        erIMTiles=cell(1,length(eIMTiles));
        egIMTiles=cell(1,length(eIMTiles));
        for k=1:length(eIMTiles)
            temp=eIMTiles{k};
            erIMTiles{k}=temp(:,:,1);   %% r channel for nuclei segmentation
            egIMTiles{k}=temp(:,:,2);   %% g channel for melanocytes detection
        end
        
        %%---- nuclei segmentation----%%
        [eNucleiTiles,eNCentroidTiles]=LSegNuclei4AllIMTiles(erIMTiles,eTiles);
        clear erIMTiles AllPtsonBnd_Basal IM_PyraimdTop temp;
        %% cal the nuclei counting info and features for the Epi sub layer
        [Nuclei_O,Nuclei_M,Nuclei_I]=LgetCountingInfo4EpiSubLayer(eNCentroidTiles,AllPtsonBnd_Keratin,MorphoInfo,ResAtcurAnaMag,'local');
        Nuclei_F=LgetFeaturesInfo4EpisubLayer(eNCentroidTiles,eNucleiTiles,eTiles,1);
        
        %% -- melanocytes segmentato----------%%
        MelaDetectPar=struct('Method','RLS','TAreaRatio',.6,'TsmalNucleiArea',80);
        %         [eMelanocyteTiles,eMCentroidTiles]...
        %             =LSegMelanocytes4AllIMTiles(egIMTiles,eTiles,eNucleiTiles,MelaDetectPar);
        tic
        eMCentroidTiles=[];
        for k=1:length(egIMTiles)
            curIMTile=egIMTiles{k};
            curMask=eTiles{k};
            curNucleiMask=eNucleiTiles{k};
            if ~isempty(curMask)&&~(sum(curNucleiMask(:))==0)
                disp(sprintf('The %dth/%d tile...\n',k,length(egIMTiles)));
                eMelanocyteTiles{k}=LDetectMelanocytes_RLS(curIMTile,curMask,curNucleiMask,MelaDetectPar.TAreaRatio,...
                    MelaDetectPar.TsmalNucleiArea);
                %%% get the locations only
                cc=bwconncomp(eMelanocyteTiles{k});
                stats=regionprops(cc,'Centroid');
                temp=[stats.Centroid];
                Centroid_x=temp(1:2:end);Centroid_y=temp(2:2:end);
                eMCentroidTiles{k}=[Centroid_y' Centroid_x'];
            else
                eMCentroidTiles{k}=[];
            end
        end
        toc
        %% cal the mealnocytes counting info for the Epi sub layer
        [Mela_O,Mela_M,Mela_I]=LgetCountingInfo4EpiSubLayer(eMCentroidTiles,AllPtsonBnd_Keratin,MorphoInfo,ResAtcurAnaMag,'local');
        Mela_F=LgetFeaturesInfo4EpisubLayer(eMCentroidTiles,eMelanocyteTiles,eTiles,0);
        clear eMCentroidTiles AllPtsonBnd_Keratin curIMTile curMask curNucleiMask temp thickness;
        %%  13 features used by PR paper
        Table=[Nuclei_O Mela_O;Nuclei_M Mela_M;Nuclei_I Mela_I]; %% the number of melanocytes with keratinocytes
        mk=Table(:,2)./Table(:,1);
        mk(isnan(mk))=0;
        Rmk_F.outter=mk(1);
        Rmk_F.middle=mk(2);
        Rmk_F.inner=mk(3);
        
        %% save features
        AllFeatures{1,index}=Nuclei_F;
        AllFeatures{2,index}=Mela_F;
        AllFeatures{3,index}=Rmk_F;
                
%         %% for debugging
%         for k=1:length(eNucleiTiles)
%             temp=eIMTiles{k};
%             temp2=eNucleiTiles{k};
%             temp3=eMelanocyteTiles{k};
%             blm=bwperim(temp2);
%             blm3=bwperim(temp3);
%             overlay1=imoverlay(temp,blm,[1 1 0]);
%             overlay1=imoverlay(overlay1,blm3,[0 1 0]);
%             s1=num2str(idx4Set);
%             s2=num2str(j);
%             s3=num2str(k);
%             s41='e.tif';
%             fname=strcat(s1,s2,s3,s41);
%             outputfilename=[Outputpath,fname];
%             imwrite(overlay1,outputfilename);
%         end
%         clear temp temp2 temp3 eIMTiles erIMTiles egIMTiles blm blm3 eTiles;
        



        
        %% dermis features construction
        [dIMTiles,dTiles]=md_epiDer(IMTiles,dfmTiles,1);  %% obtain dermis for efficiency
        %% evaluation dermis segmentation
        %        ev_showBound(IM_PyraimdTop,dermisMaskTop,'b');
        drIMTiles=cell(1,length(dIMTiles));
        for k=1:length(dIMTiles)
            temp=dIMTiles{k};
            drIMTiles{k}=temp(:,:,1);  %% use only red channel
        end
        clear temp dfmTiles;
        His_F=md_histogramFeats(drIMTiles,dTiles);                     %% histogram features
        Hara_F=md_haralickFeats(drIMTiles,dTiles);                      %% Haralick features
        
        AllFeatures{4,index}=His_F;
        AllFeatures{5,index}=Hara_F;
        
        %% image binarization
        ac=30;                                                             %% remove isolated pixels
        nMask=cell(1,length(drIMTiles));
        nIMask=cell(1,length(drIMTiles));
        cNIs=cell(1,length(drIMTiles));               %% isolated nuclei centroids
        dNuSeg=cell(1,length(drIMTiles));             %% for showing intermediate results
        for k=1:length(drIMTiles)
            overlay1=dIMTiles{k};
            
            drTile=drIMTiles{k};
            dMask=dTiles{k};
            [nMask{k},nIMask{k}]=md_imageBinarization(drTile,dMask,ac);                %% Predefined thresholding based binarization
            curC=regionprops(nIMask{k},'centroid');
            cNIs{k}=cat(1,curC.Centroid);
            
            blm=bwperim(nIMask{k});
            overlay1=imoverlay(overlay1,blm,[0 1 0]);
            dNuSeg{k}=overlay1;
            
            %            ev_showBound(dIMTiles{k},nMask{k},'g',1);
            %            ev_showBound(dIMTiles{k},nIMask{k},'r');
            
        end
        
        %% gLoG based nuclei detection
        Para.thetaStep=pi/9;
        Para.largeSigma=8;
        Para.smallSigma=4;
        Para.sigmaStep=-1;
        Para.kerSize=Para.largeSigma*4;
        Para.bandwidth=5;
        Ncs=cell(1,length(drIMTiles)); %% save nuclei seeds
        for k=1:length(drIMTiles)
            drTile=drIMTiles{k};
            Nmask=nMask{k};
            Ncs{k}=md_nucleiDetection(drTile,Nmask,Para);
        end
        
        %         %% radial line scanning based segmentation
        %         %% do not consider the seeds on image borders as those are parts of nuclei
        
        [Rd0,St0,nucleiCens,dNuSeg]=md_nucleiSegmentation(drIMTiles,Ncs,cNIs,dNuSeg);
        
        
%         %% for debugging
%         for k=1:length(dNuSeg)
%             overlay1=dNuSeg{k};
%             s1=num2str(idx4Set);
%             s2=num2str(j);
%             s3=num2str(k);
%             s41='d.tif';
%             fname=strcat(s1,s2,s3,s41);
%             outputfilename=[Outputpath2,fname];
%             imwrite(overlay1,outputfilename);
%         end
        
        clear Nmask Ncs dNuSeg IMTiles;
        %%(i) regional descriptors
        Rd1=[];
        for k=1:length(nIMask)
            NImask=nIMask{k};
            Rd=regionprops(NImask,'Area','Eccentricity','MajorAxisLength','MinorAxisLength','Perimeter','EquivDiameter');
            %             per=[Rd.Perimeter];   %% use brackets to get all values
            %             area=[Rd.Area];
            %             pr=per./(sqrt(area));  %% perimeter ratio to measure boundary irregularities
            %             prArray=num2cell(pr);
            %             [Rd.Pratio]=deal(prArray{:});
            ar=[Rd.MajorAxisLength]./[Rd.MinorAxisLength];
            Rdt=struct('Area',{Rd.Area}','Eccentricity',{Rd.Eccentricity}','Perimeter',{Rd.Perimeter}',...
                'EquivDiameter',{Rd.EquivDiameter}');
            prArray=num2cell(ar);
            [Rdt.AxisRatio]=deal(prArray{:});
            
            Rd1=[Rd1;Rdt];
        end
        Rdf=[Rd1;Rd0];
        Cf=struct2cell(Rdf);
        RdMat=cell2mat(Cf);   %% 5xN Array
        Rdm=mean(RdMat,2);
        Rds=std(RdMat,[],2);
        Rd_F.mean_area=Rdm(1);
        Rd_F.mean_eccentricity=Rdm(2);
        Rd_F.mean_perimeter=Rdm(3);
        Rd_F.mean_equivdiameter=Rdm(4);
        Rd_F.mean_axisratio=Rdm(5);
        %       Rd_F.mean_pratio=Rdm(6);
        Rd_F.std_area=Rds(1);
        Rd_F.std_eccentricity=Rds(2);
        Rd_F.std_perimeter=Rds(3);
        Rd_F.std_equivdiameter=Rds(4);
        Rd_F.std_axisratio=Rds(5);
        %        Rd_F.std_pratio=Rds(6);
        
        %(ii) statistical texture features
        % average intensity, average contrast,smoothness, third moment, uniformity,
        % and entropy
        St1=[];
        for k=1:length(nIMask)
            NImask=nIMask{k};
            drTile=drIMTiles{k};
            St=md_mstatxture(drTile,NImask); % from red channel
            St1=[St1,St];
        end
        StMat=[St1,St0];
        Stm=mean(StMat,2);
        Sts=std(StMat,[],2);
        St_F.mean_intensity=Stm(1);
        St_F.mean_contrast=Stm(2);
        St_F.mean_smoothness=Stm(3);
        St_F.mean_thirdmoment=Stm(4);
        St_F.mean_uniformity=Stm(5);
        St_F.mean_entropy=Stm(6);
        St_F.std_intensity=Sts(1);
        St_F.std_contrast=Sts(2);
        St_F.std_smoothness=Sts(3);
        St_F.std_thirdmoment=Sts(4);
        St_F.std_uniformity=Sts(5);
        St_F.std_entropy=Sts(6);
        
        %% (iii) Delaunay and Voronoi diagram features
        
        Gf_F=md_graphFeats(nucleiCens,dTiles);
        
         AllFeatures{6,index}=Rd_F;
         AllFeatures{7,index}=St_F;
         AllFeatures{8,index}=Gf_F;
         
        index=index+1
        
        
        
        %
        %         %% save measured thickenss (for experiments)
        %         %         thickness=zeros(1,3);
        %         %         for i=1:3
        %         %             h=imline;
        %         %             temp=h.getPosition();
        %         %             thickness(1,i)=sqrt((temp(1,1)-temp(2,1))^2+(temp(1,2)-temp(2,2))^2);
        %         %         end
        %         %         thickness=thickness.*(4*ResAtcurAnaMag);
        %         %         num=sprintf('%d',idx4Set);
        %         %         imagetype='_melanoma';
        %         %         imagename=wholeFilename(end-9:end-4);
        %         %         image=strcat(num,imagetype,imagename,'.mat');
        %         %         save(image,'thickness');
        %
        %
        %         %         num=sprintf('%d',idx4Set);
        %         %         imagetype='_melanoma';
        %         %         imagename=wholeFilename(end-9:end);
        %         %         image=strcat(num,imagetype,imagename);
        %         %         saveas(gcf,image);
        %         %         close all;
        %         %
        %
        %
        %
        %
        %
        %
        %         %     num=sprintf('%d',idx4Set);
        %         %     imagetype='_normal';
        %         %     imagename=wholeFilename(end-9:end-4);
        %         %     image=strcat(num,imagetype,imagename,'.mat');
        %         %     save(image,'AllIMTiles');
        %         %     close all;
    end  
end
outfilename=sprintf('%s%s.mat',Outputpath3,'nevus');
save(outfilename,'AllFeatures');