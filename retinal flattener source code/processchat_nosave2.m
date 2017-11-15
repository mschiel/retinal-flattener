function [VZminmesh,VZmaxmesh]=processchat_nosave2(imst2,smoothing,maxthick,singlesurface,ignorecols,imst11)
h = waitbar(0,'Please Wait... Creating ChAT Surfaces from Channel 1');
warning off all
clear imstackfilt chatimage2 totalchat
totalchat=logical(0.*imst11(:,:,1));
for i=1:size(imst11,3)
totalchat=totalchat|((imst2(:,:,i)-imst11(:,:,i))>0);
end
totalchat=imcomplement(totalchat);
for i=1:size(imst11,3)
imstackfilt(:,:,i)=imresize(imst2(:,:,i),0.33);
if ignorecols
    chatimage2(:,:,i)=imresize(255.*totalchat,0.33);
else
    chatimage2(:,:,i)=imresize(imst11(:,:,i),0.33);
end
end
% imstackfilt=imst10;
% chatimage2=imst10;
clear maxtab mintab peaks chatmax chatmin chatmaxval chatminval dvec
n=1;
fsize=20;
stdthresh=0.001;
xsize=size(imstackfilt,1);%1024;
ysize=size(imstackfilt,2);%1024;
for i=1:xsize
    waitbar(i/xsize,h);
for j=1:ysize
    try
        clear maxtab maxtab2
    end
    chatmax(i,j)=nan;
    chatmin(i,j)=nan;
    chatmaxval(i,j)=nan;
    chatminval(i,j)=nan;
    vec1=squeeze(single(imstackfilt(i,j,:)));
    zvec=smooth(vec1,3);
    [maxtab,~]=peakdet(uint8(zvec),0.5);
%     zvec2=zvec-smooth(zvec,10);
%     [maxtab2,mintab2]=peakdet(uint8(zvec2),0.5);
    chatvec=chatimage2(i,j,:);
        n=1;
if (size(maxtab,1)>0)
    for k=1:size(maxtab,1)
        maxtab(k,2)=maxtab(k,2).*uint8(chatvec(maxtab(k,1))>1).*uint8(maxtab(k,2)>50);
        if maxtab(k,2)>0
            maxtab2(n,1)=maxtab(k,1);
            maxtab2(n,2)=maxtab(k,2);
            n=n+1;
        end
    end
%     maxtab = maxtab(all(maxtab,2),:);
end
if n>1
if singlesurface
    if (size(maxtab2,1)>=1)
[newmaxval,newmaxind]=sort(maxtab2(:,2),'descend');
newmaxtab=[maxtab2(newmaxind,1) newmaxval];
[cmax,cmaxind]=min([newmaxtab(1,1)]);
[cmin,cminind]=min([newmaxtab(1,1)]);
chatmax(i,j)=double(cmax);
chatmin(i,j)=double(cmin);
chatmaxval(i,j)=double(newmaxtab(cmaxind,2));
chatminval(i,j)=double(newmaxtab(cminind,2));
    end
else
if (size(maxtab2,1)>=2)
    [newmaxval,newmaxind]=sort(maxtab2(:,2),'descend');
    newmaxtab=[maxtab2(newmaxind,1) newmaxval];
    [newmaxval,newmaxind]=sort(newmaxtab(1:2,1),'descend');
%     newmaxtab=[newmaxtab(newmaxind,1) newmaxval];
    newmaxtab=[newmaxval newmaxtab(newmaxind,2)];
if (abs(newmaxtab(1,1)-newmaxtab(2,1))<maxthick)
[cmax,cmaxind]=max([newmaxtab(1,1) newmaxtab(2,1)]);
[cmin,cminind]=min([newmaxtab(1,1) newmaxtab(2,1)]);
chatmax(i,j)=double(cmax);
chatmin(i,j)=double(cmin);
chatmaxval(i,j)=double(newmaxtab(cmaxind,2));
chatminval(i,j)=double(newmaxtab(cminind,2));
% n=n+1;
end
end
end
end

end
end
max(chatmax(:))
[X,Y]=meshgrid(1:xsize,1:ysize);
peaksmax=[X(:) Y(:) chatmax(:)];
peaksmin=[X(:) Y(:) chatmin(:)];
ptCloud=pointCloud(single(peaksmax));
ptCloudOut = pcdenoise(ptCloud,'Threshold',0.25,'NumNeighbors',30);
peaksmax2=ptCloudOut.Location;
ptCloud=pointCloud(single(peaksmin));
ptCloudOut = pcdenoise(ptCloud,'Threshold',0.25,'NumNeighbors',30);
peaksmin2=ptCloudOut.Location;
% scatter3(peaksmax2(:,1),peaksmax2(:,2),peaksmax2(:,3),'.')
% hold
% scatter3(peaksmin2(:,1),peaksmin2(:,2),peaksmin2(:,3),'.r')
xnodes = 1:xsize;
ynodes = 1:ysize;
smoothfactor=smoothing;
VZminmesh = gridfit(peaksmin2(:,2),peaksmin2(:,1),peaksmin2(:,3), ynodes, xnodes, ...
        'regularizer', 'gradient', 'smooth', smoothfactor);
if singlesurface
    VZmaxmesh=VZminmesh;
else
VZmaxmesh = gridfit(peaksmax2(:,2),peaksmax2(:,1),peaksmax2(:,3), ynodes, xnodes, ...
        'regularizer', 'gradient', 'smooth', smoothfactor);
end
%save(outputhdf5file,'-v7.3')
delete(h);