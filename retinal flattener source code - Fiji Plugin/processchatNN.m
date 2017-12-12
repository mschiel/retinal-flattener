function chatstruct=processchatNN(chat,smoothing)



load NNParams.mat;

smallx=floor(size(chat,2)/10);
smally=floor(size(chat,1)/10);

smallchatcomplete=zeros(smally,smallx,size(chat,3));

for i=1:size(chat,3)
    smallchatcomplete(:,:,i)=imresize(chat(:,:,i),[smally smallx],'bilinear');%*(1+0.8*i/size(a.chat,3));
end

smallchat=[];

for i=2:2:size(chat,3)
smallchat(:,:,i/2)=smallchatcomplete(:,:,i);
end
smallchat=permute(smallchat,[1 3 2]);

smallchat=double(smallchat)/max(smallchat(:));

output=NNpass(W,B,smallchat,num_of_maps_in_layer);
CHAT=output{3}>0.5*max(output{3}(:));
%CHAT=bwareaopen(CHAT,1000);
CHAT=bwareaopen(CHAT,1000);

% if there are more than two components
l=bwlabeln(CHAT);
if max(l(:))>2
    for i=1:max(l(:))
        avg(i)=mean(output{3}(l==i));
    end
    [v ind]=min(avg);
    CHAT(l==ind)=0;
end

% fix small holes
smallchat=permute(smallchat,[1 3 2]);
CHAT=permute(CHAT,[1 3 2]);

outchat=zeros(size(smallchat));
for i=7:size(smallchat,3)-6
    outchat(7:end-6,7:end-6,i)=CHAT(:,:,i-6);
end


%CHAT=permute(CHAT,[1 3 2]);

histfg=smallchat(outchat(:)>0);
a=sort(histfg);
thres=a(round(length(histfg)*0.98));

% get rid of bright somas

enhanced=smallchat;
enhanced=permute(enhanced,[1 3 2]);

for i=1:size(enhanced,3)
    enhanced(:,:,i)=medfilt2(enhanced(:,:,i),[2 10],'symmetric');
%    enhanced(:,:,i)=filter2(ones(3,20)/15,enhanced(:,:,i),'same');%-filter2(ones(3,5)/5,enhanced(:,:,i),'same');
end
 enhanced=permute(enhanced,[1 3 2]);
 
 enhanced=permute(enhanced,[3 2 1]);
for i=1:size(enhanced,3)
    enhanced(:,:,i)=medfilt2(enhanced(:,:,i),[10 2],'symmetric');
%    enhanced(:,:,i)=filter2(ones(3,20)/15,enhanced(:,:,i),'same');%-filter2(ones(3,5)/5,enhanced(:,:,i),'same');
end
 enhanced=permute(enhanced,[3 2 1]);


for i=1:size(enhanced,3)
   enhanced(:,:,i)=medfilt2(enhanced(:,:,i),[2 2])-medfilt2(enhanced(:,:,i),[6 6],'symmetric');
%    filter2(ones(3,3)/9,smallchat(:,:,i),'same')-filter2(ones(7,7)/225,smallchat(:,:,i),'same'); 
end

enhancedfull=[];
for i=1:size(smallchatcomplete,3)
   enhancedfull(:,:,i)=enhanced(:,:,min(ceil(i/2),size(enhanced,3)));
%    filter2(ones(3,3)/9,smallchat(:,:,i),'same')-filter2(ones(7,7)/225,smallchat(:,:,i),'same'); 
end




% pick out the centers of the cells
l=enhancedfull>max(enhanced(outchat(:)>0));
%lo=enhanced>max(enhanced(
lbig=imdilate(l,strel('arbitrary',ones([5 5 5])));

outsmally=round(smally/5);
outsmallx=round(smallx/5);
smallchatcomplete(smallchatcomplete>thres*max(smallchatcomplete(:)))=thres*max(smallchatcomplete(:));
smallchatNN=[];
for i=1:1:size(chat,3)
    smallchatNN(:,:,i)=imresize(smallchatcomplete(:,:,i),[outsmally outsmallx],'bilinear');%*(1+0.8*i/size(a.chat,3));
end

somas=zeros(size(smallchatcomplete));
props=regionprops(bwlabeln(l));
% for i=1:length(props)
%     props(i).Centroid=round(props(i).Centroid);
%     xextend=max(props(i).Centroid(1)-4,1):min(props(i).Centroid(1)+4,size(enhanced,2));
%     yextend=max(props(i).Centroid(2)-4,1):min(props(i).Centroid(2)+4,size(enhanced,1));
%     zextend=max(props(i).Centroid(3)-10,1):min(props(i).Centroid(3)+10,size(enhancedfull,3));
%     somas(yextend,xextend,zextend)=1;
% end


somas(lbig)=1;

smallchatsoma=[];
for i=1:1:size(chat,3)
    smallchatsoma(:,:,i)=imresize(somas(:,:,i),[outsmally outsmallx],'bilinear');%*(1+0.8*i/size(a.chat,3));
end

                % bring back chat pixels
% suppress very bright pixels

smallchat=smallchatNN;


outchat=zeros(size(smallchatNN));
for i=13:size(chat,3)-12
    chatslice=zeros(smally,smallx);
    chatslice(7:end-6,7:end-6)=CHAT(:,:,min(ceil((i-12)/2),size(CHAT,3)));
    outchat(:,:,i)=imresize(chatslice,[outsmally outsmallx],'bilinear');
end
%outchat=imdilate(outchat>0,strel(ones(5,5,1)));


% outchat=permute(outchat,[1 3 2]);
% for i=1:size(outchat,3)
%     outchat(:,:,i)=imdilate(outchat(:,:,i),strel('rectangle',[3 8]));
% end
% outchat=permute(outchat,[1 3 2]);

% extrapolate to the edges
outchat(1,:,:)=reshape(imdilate(squeeze(outchat(2,:,:)),strel('square',4)),[1 size(outchat,2) size(outchat,3)]);
outchat(outsmally,:,:)=reshape(imdilate(squeeze(outchat(outsmally-1,:,:)),strel('square',4)),[1 size(outchat,2) size(outchat,3)]);
outchat(:,1,:)=reshape(imdilate(squeeze(outchat(:,2,:)),strel('square',4)),[size(outchat,1) 1 size(outchat,3)]);
outchat(:,outsmallx,:)=reshape(imdilate(squeeze(outchat(:,outsmallx-1,:)),strel('square',4)),[size(outchat,1) 1 size(outchat,3)]);

outchatthin=outchat;


outchat=permute(outchat,[1 3 2]);
for i=1:size(outchat,3)
    outchat(:,:,i)=imdilate(outchat(:,:,i),strel('rectangle',[4 4]));
end
outchat=permute(outchat,[1 3 2])>0;

smallchatNN(outchat==0)=0;
smallchat1=smallchatNN;

smallchatsoma(outchat>0)=0;

% smallchat1=smallchat;


% 
% for i=1:size(smallchat,3)
%     smallchat(:,:,i)=  filter2(ones(10,10)/100,smallchat(:,:,i),'same');
% end

% smallchat1=[];
% for i=1:size(smallchat,3)
%     smallchat1(:,:,i)=imresize(smallchat(:,:,i),[20 20],'bilinear'); %'box'
% end

% smalldapi1=[];
% for i=1:size(smalldapi,3)
%     smalldapi1(:,:,i)=imresize(smalldapi(:,:,i),[20 20],'bilinear'); %'box'
% end


%  zprofdapi=squeeze(mean(mean(dapi,1),2));
%  zmin=find(imregionalmin(zprofdapi));
%  % find the one closest to the center
%  [val zcentermin]=min(abs(zmin-size(dapi,3)/2));
%  zcentermin=zmin(zcentermin);


chatzmin=[];
chatzmax=[];
% get the chat bands
for i=1:size(smallchatNN,1)
    for j=1:size(smallchatNN,2)
        
        % does outchat has two nice peaks indicating success of NN
        % algorithm?
        
        zprof=smallchat(i,j,:);
        zprof=smooth(zprof,5);
        [maxtab mintab]=peakdet(zprof,0.5);

        peaks=zeros(size(zprof));
        for k=1:size(maxtab,1)
           peaks(maxtab(k,1))=maxtab(k,2);
        end
        peaks(outchat(i,j,:)==0)=0;
        % are the peaks 10 slices apart?
        if sum(peaks>0)>=2 
            a=sort(peaks,'descend');
            ind=find(peaks>=a(2));
            if (ind(2)-ind(1))>0
                chatzmin(i,j)=ind(1);
                chatzmax(i,j)=ind(2);
                continue;
            end
        end
        
        
        % suppress really broad peaks
        zprof1=zprof-smooth(zprof,15);
        [maxtab mintab]=peakdet(zprof1,0.5);

        peaks=zeros(size(zprof1));
        for k=1:size(maxtab,1)
           peaks(maxtab(k,1))=maxtab(k,2);
        end
        peaks(smallchatsoma(i,j,:)>0)=0;
        
      %  maxtab=maxtab(maxtab(:,2)>max(zprof)*0.5
        
        
            
        
        
%         zprof=outchatthin(i,j,:);
%         [maxtab mintab]=peakdet(zprof,0.5);
%         
%         
%         
%         
%         zprof=smallchat1(i,j,:);
%         zprof=zprof-min(zprof);
% %         zprofdapi=smalldapi1(i,j,:);
% %         zprofdapi=zprofdapi-min(zprofdapi);
% %         zprof(zprofdapi(1:zcentermin)>max(zprofdapi(1:zcentermin))*0.5)=0;
% %         zprof(zcentermin+find(zprofdapi(zcentermin+1:end)>max(zprofdapi(zcentermin+1:end))*0.5))=0;
% %         %        zprof=medfilt2(zprof(:),[10 1]);
%      
%         zprof(zprof<max(zprof)*0.3)=0;
        [maxtab mintab]=peakdet(peaks,0.5);
        zmax=maxtab(:,1);
        % get rid of peaks near boundary
        zmax(zmax<5)=[];
        zmax(zmax>length(zprof)-5)=[];
        if length(zmax)==0
            chatzmin(i,j)=0;
            chatzmax(i,j)=1;
        else
            if length(zmax)==1
                chatzmin(i,j)=zmax-8;
                chatzmax(i,j)=zmax+8;
            else

                if length(zmax)>2
%                     i
%                     j
                end

                % two highest peaks
                [peaks ind]=sort(zprof1(zmax),'descend');
                chatzmin(i,j)=zmax(min(ind(1:2)));
                chatzmax(i,j)=zmax(max(ind(1:2)));
            end
        end
    end
end

%rehabitate the problem spots
chatzminfilt=medfilt2(chatzmin,'symmetric');
ind=abs(chatzmin-chatzminfilt)>5;
chatzmin(ind)=chatzminfilt(ind);

chatzmaxfilt=medfilt2(chatzmax,'symmetric');
ind=abs(chatzmax-chatzmaxfilt)>5;
chatzmax(ind)=chatzmaxfilt(ind);

chatzminfilt=medfilt2(chatzmin,'symmetric',[5 5]);
ind=abs(chatzmin-chatzminfilt)>10;
chatzmin(ind)=chatzminfilt(ind);

chatzmaxfilt=medfilt2(chatzmax,'symmetric',[5 5]);
ind=abs(chatzmax-chatzmaxfilt)>10;
chatzmax(ind)=chatzmaxfilt(ind);



% chatzmin= size(chat,3)-chatzmin+1;
% chatzmax= size(chat,3)-chatzmax+1;
stepx=round(size(chat,2)/(1*size(chatzmin,2)));
stepy=round(size(chat,1)/(1*size(chatzmin,1)));


chatx = round(stepx/2):stepx:size(chat,2);
chaty = round(stepy/2):stepy:size(chat,1);
[chatX chatY]=meshgrid(chatx, chaty);

smoothfactor = smoothing;
x = 1:3:size(chat,2);
y = 1:3:size(chat,1);
[X Y] = meshgrid(x,y);

zminmesh = gridfit(chatX, chatY,chatzmin, x, y, ...
        'regularizer', 'gradient', 'smooth', smoothfactor);
zmaxmesh = gridfit(chatX, chatY,chatzmax, x, y, ...
        'regularizer', 'gradient', 'smooth', smoothfactor);

enhanced=[];


zminmesh=max(1,min(zminmesh,size(chat,3)));
zmaxmesh=max(1,min(zmaxmesh,size(chat,3)));


% assign nuclear centers



% create a normalized plot

chatstruct.chatX=chatX;
chatstruct.chatY=chatY;
chatstruct.zminmesh=zminmesh;
chatstruct.zmaxmesh=zmaxmesh;
chatstruct.chatzmin=chatzmin;
chatstruct.chatzmax=chatzmax;
centroids = cat(1, props.Centroid);

% following code has problems
chatstruct.nuclgcl=centroids(zminmesh((1+floor((centroids(:,1)-1)/50))*25+floor((-1+centroids(:,2))/50)+1)>centroids(:,3),:);
chatstruct.nuclinl=centroids(zmaxmesh((1+floor((centroids(:,1)-1)/50))*25+floor((-1+centroids(:,2))/50)+1)<centroids(:,3),:);
chatstruct.nuclgcl(:,1)=chatstruct.nuclgcl(:,1)*5;
chatstruct.nuclinl(:,1)=chatstruct.nuclinl(:,1)*5;
chatstruct.nuclgcl(:,2)=chatstruct.nuclgcl(:,2)*5;
chatstruct.nuclinl(:,2)=chatstruct.nuclinl(:,2)*5;



projchatx=squeeze(mean(chat,2));
projchaty=squeeze(mean(chat,1));

visualize=0;
if (visualize)
                    figure(14), clf;
                   
                    surf(X, Y, chatstruct.zminmesh, 'EdgeColor', 'none');
                    hold on
                    surf(X, Y, chatstruct.zmaxmesh, 'EdgeColor', 'none');
                    shading interp, camlight left;
                    scatter3(chatstruct.chatX(:), chatstruct.chatY(:), chatstruct.chatzmin(:), 'bo', 'filled');
                    scatter3(chatstruct.chatX(:), chatstruct.chatY(:), chatstruct.chatzmax(:), 'ro', 'filled');
                    % axis image
                    set(gca, 'XLim', [1 1500]);
                    set(gca, 'YLim', [1 1500]);
                    set(gca, 'ZLim', [1 size(chat,3)]);
                    title('DAPI IPL Boundary Localization')
                    colorbar
end
                
browse=0;
x = 1:3:size(chat,2);
y = 1:3:size(chat,1);
[X Y] = meshgrid(x,y);

%calculate an index for every pixel
[xi,yi]=meshgrid(1:size(chat,2),1:size(chat,1));
meanmin=mean(zminmesh(:));
meanmax=mean(zmaxmesh(:));
VZminmesh=interp2(X,Y,zminmesh,xi,yi,'*linear',meanmin);
VZmaxmesh=interp2(X,Y,zmaxmesh,xi,yi,'*linear',meanmax);


%%newstack=zeros(size(chat),'single');
%%newstack((1:size(chat,1)*size(chat,2))'+floor(VZmaxmesh(:))*size(chat,1)*size(chat,2))=3;
%%newstack((1:size(chat,1)*size(chat,2))'+floor(VZminmesh(:))*size(chat,1)*size(chat,2))=4;   

chatstruct.VZminmesh=VZminmesh;
chatstruct.VZmaxmesh=VZmaxmesh;
%%chatstruct.chatstack=newstack;

if (browse)
%%BrowseComponents('ii',chat,newstack);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [zgrid,xgrid,ygrid] = gridfit(x,y,z,xnodes,ynodes,varargin)
%--------------------------%
%Copyright (c) 2006, John D'Errico
%All rights reserved.

%Redistribution and use in source and binary forms, with or without
%modification, are permitted provided that the following conditions are
%met:

%    * Redistributions of source code must retain the above copyright
%      notice, this list of conditions and the following disclaimer.
%    * Redistributions in binary form must reproduce the above copyright
%      notice, this list of conditions and the following disclaimer in
%      the documentation and/or other materials provided with the distribution

%THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
%AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
%IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
%ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
%LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
%CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
%SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
%INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
%CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
%ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
%POSSIBILITY OF SUCH DAMAGE.
%--------------------------%

% gridfit: estimates a surface on a 2d grid, based on scattered data
%          Replicates are allowed. All methods extrapolate to the grid
%          boundaries. Gridfit uses a modified ridge estimator to
%          generate the surface, where the bias is toward smoothness.
%
%          Gridfit is not an interpolant. Its goal is a smooth surface
%          that approximates your data, but allows you to control the
%          amount of smoothing.
%
% usage #1: zgrid = gridfit(x,y,z,xnodes,ynodes);
% usage #2: [zgrid,xgrid,ygrid] = gridfit(x,y,z,xnodes,ynodes);
% usage #3: zgrid = gridfit(x,y,z,xnodes,ynodes,prop,val,prop,val,...);
%
% Arguments: (input)
%  x,y,z - vectors of equal lengths, containing arbitrary scattered data
%          The only constraint on x and y is they cannot ALL fall on a
%          single line in the x-y plane. Replicate points will be treated
%          in a least squares sense.
%
%          ANY points containing a NaN are ignored in the estimation
%
%  xnodes - vector defining the nodes in the grid in the independent
%          variable (x). xnodes need not be equally spaced. xnodes
%          must completely span the data. If they do not, then the
%          'extend' property is applied, adjusting the first and last
%          nodes to be extended as necessary. See below for a complete
%          description of the 'extend' property.
%
%          If xnodes is a scalar integer, then it specifies the number
%          of equally spaced nodes between the min and max of the data.
%
%  ynodes - vector defining the nodes in the grid in the independent
%          variable (y). ynodes need not be equally spaced.
%
%          If ynodes is a scalar integer, then it specifies the number
%          of equally spaced nodes between the min and max of the data.
%
%          Also see the extend property.
%
%  Additional arguments follow in the form of property/value pairs.
%  Valid properties are:
%    'smoothness', 'interp', 'regularizer', 'solver', 'maxiter'
%    'extend', 'tilesize', 'overlap'
%
%  Any UNAMBIGUOUS shortening (even down to a single letter) is
%  valid for property names. All properties have default values,
%  chosen (I hope) to give a reasonable result out of the box.
%
%   'smoothness' - scalar or vector of length 2 - determines the
%          eventual smoothness of the estimated surface. A larger
%          value here means the surface will be smoother. Smoothness
%          must be a non-negative real number.
%
%          If this parameter is a vector of length 2, then it defines
%          the relative smoothing to be associated with the x and y
%          variables. This allows the user to apply a different amount
%          of smoothing in the x dimension compared to the y dimension.
%
%          Note: the problem is normalized in advance so that a
%          smoothness of 1 MAY generate reasonable results. If you
%          find the result is too smooth, then use a smaller value
%          for this parameter. Likewise, bumpy surfaces suggest use
%          of a larger value. (Sometimes, use of an iterative solver
%          with too small a limit on the maximum number of iterations
%          will result in non-convergence.)
%
%          DEFAULT: 1
%
%
%   'interp' - character, denotes the interpolation scheme used
%          to interpolate the data.
%
%          DEFAULT: 'triangle'
%
%          'bilinear' - use bilinear interpolation within the grid
%                     (also known as tensor product linear interpolation)
%
%          'triangle' - split each cell in the grid into a triangle,
%                     then linear interpolation inside each triangle
%
%          'nearest' - nearest neighbor interpolation. This will
%                     rarely be a good choice, but I included it
%                     as an option for completeness.
%
%
%   'regularizer' - character flag, denotes the regularization
%          paradignm to be used. There are currently three options.
%
%          DEFAULT: 'gradient'
%
%          'diffusion' or 'laplacian' - uses a finite difference
%              approximation to the Laplacian operator (i.e, del^2).
%
%              We can think of the surface as a plate, wherein the
%              bending rigidity of the plate is specified by the user
%              as a number relative to the importance of fidelity to
%              the data. A stiffer plate will result in a smoother
%              surface overall, but fit the data less well. I've
%              modeled a simple plate using the Laplacian, del^2. (A
%              projected enhancement is to do a better job with the
%              plate equations.)
%
%              We can also view the regularizer as a diffusion problem,
%              where the relative thermal conductivity is supplied.
%              Here interpolation is seen as a problem of finding the
%              steady temperature profile in an object, given a set of
%              points held at a fixed temperature. Extrapolation will
%              be linear. Both paradigms are appropriate for a Laplacian
%              regularizer.
%
%          'gradient' - attempts to ensure the gradient is as smooth
%              as possible everywhere. Its subtly different from the
%              'diffusion' option, in that here the directional
%              derivatives are biased to be smooth across cell
%              boundaries in the grid.
%
%              The gradient option uncouples the terms in the Laplacian.
%              Think of it as two coupled PDEs instead of one PDE. Why
%              are they different at all? The terms in the Laplacian
%              can balance each other.
%
%          'springs' - uses a spring model connecting nodes to each
%              other, as well as connecting data points to the nodes
%              in the grid. This choice will cause any extrapolation
%              to be as constant as possible.
%
%              Here the smoothing parameter is the relative stiffness
%              of the springs connecting the nodes to each other compared
%              to the stiffness of a spting connecting the lattice to
%              each data point. Since all springs have a rest length
%              (length at which the spring has zero potential energy)
%              of zero, any extrapolation will be minimized.
%
%          Note: The 'springs' regularizer tends to drag the surface
%          towards the mean of all the data, so too large a smoothing
%          parameter may be a problem.
%
%
%   'solver' - character flag - denotes the solver used for the
%          resulting linear system. Different solvers will have
%          different solution times depending upon the specific
%          problem to be solved. Up to a certain size grid, the
%          direct \ solver will often be speedy, until memory
%          swaps causes problems.
%
%          What solver should you use? Problems with a significant
%          amount of extrapolation should avoid lsqr. \ may be
%          best numerically for small smoothnesss parameters and
%          high extents of extrapolation.
%
%          Large numbers of points will slow down the direct
%          \, but when applied to the normal equations, \ can be
%          quite fast. Since the equations generated by these
%          methods will tend to be well conditioned, the normal
%          equations are not a bad choice of method to use. Beware
%          when a small smoothing parameter is used, since this will
%          make the equations less well conditioned.
%
%          DEFAULT: 'normal'
%
%          '\' - uses matlab's backslash operator to solve the sparse
%                     system. 'backslash' is an alternate name.
%
%          'symmlq' - uses matlab's iterative symmlq solver
%
%          'lsqr' - uses matlab's iterative lsqr solver
%
%          'normal' - uses \ to solve the normal equations.
%
%
%   'maxiter' - only applies to iterative solvers - defines the
%          maximum number of iterations for an iterative solver
%
%          DEFAULT: min(10000,length(xnodes)*length(ynodes))
%
%
%   'extend' - character flag - controls whether the first and last
%          nodes in each dimension are allowed to be adjusted to
%          bound the data, and whether the user will be warned if
%          this was deemed necessary to happen.
%
%          DEFAULT: 'warning'
%
%          'warning' - Adjust the first and/or last node in
%                     x or y if the nodes do not FULLY contain
%                     the data. Issue a warning message to this
%                     effect, telling the amount of adjustment
%                     applied.
%
%          'never'  - Issue an error message when the nodes do
%                     not absolutely contain the data.
%
%          'always' - automatically adjust the first and last
%                     nodes in each dimension if necessary.
%                     No warning is given when this option is set.
%
%
%   'tilesize' - grids which are simply too large to solve for
%          in one single estimation step can be built as a set
%          of tiles. For example, a 1000x1000 grid will require
%          the estimation of 1e6 unknowns. This is likely to
%          require more memory (and time) than you have available.
%          But if your data is dense enough, then you can model
%          it locally using smaller tiles of the grid.
%
%          My recommendation for a reasonable tilesize is
%          roughly 100 to 200. Tiles of this size take only
%          a few seconds to solve normally, so the entire grid
%          can be modeled in a finite amount of time. The minimum
%          tilesize can never be less than 3, although even this
%          size tile is so small as to be ridiculous.
%
%          If your data is so sparse than some tiles contain
%          insufficient data to model, then those tiles will
%          be left as NaNs.
%
%          DEFAULT: inf
%
%
%   'overlap' - Tiles in a grid have some overlap, so they
%          can minimize any problems along the edge of a tile.
%          In this overlapped region, the grid is built using a
%          bi-linear combination of the overlapping tiles.
%
%          The overlap is specified as a fraction of the tile
%          size, so an overlap of 0.20 means there will be a 20%
%          overlap of successive tiles. I do allow a zero overlap,
%          but it must be no more than 1/2.
%
%          0 <= overlap <= 0.5
%
%          Overlap is ignored if the tilesize is greater than the
%          number of nodes in both directions.
%
%          DEFAULT: 0.20
%
%
%   'autoscale' - Some data may have widely different scales on
%          the respective x and y axes. If this happens, then
%          the regularization may experience difficulties. 
%          
%          autoscale = 'on' will cause gridfit to scale the x
%          and y node intervals to a unit length. This should
%          improve the regularization procedure. The scaling is
%          purely internal. 
%
%          autoscale = 'off' will disable automatic scaling
%
%          DEFAULT: 'on'
%
%
% Arguments: (output)
%  zgrid   - (nx,ny) array containing the fitted surface
%
%  xgrid, ygrid - as returned by meshgrid(xnodes,ynodes)
%
%
% Speed considerations:
%  Remember that gridfit must solve a LARGE system of linear
%  equations. There will be as many unknowns as the total
%  number of nodes in the final lattice. While these equations
%  may be sparse, solving a system of 10000 equations may take
%  a second or so. Very large problems may benefit from the
%  iterative solvers or from tiling.
%
%
% Example usage:
%
%  x = rand(100,1);
%  y = rand(100,1);
%  z = exp(x+2*y);
%  xnodes = 0:.1:1;
%  ynodes = 0:.1:1;
%
%  g = gridfit(x,y,z,xnodes,ynodes);
%
% Note: this is equivalent to the following call:
%
%  g = gridfit(x,y,z,xnodes,ynodes, ...
%              'smooth',1, ...
%              'interp','triangle', ...
%              'solver','normal', ...
%              'regularizer','gradient', ...
%              'extend','warning', ...
%              'tilesize',inf);
%
%
% Author: John D'Errico
% e-mail address: woodchips@rochester.rr.com
% Release: 2.0
% Release date: 5/23/06

% set defaults
params.smoothness = 1;
params.interp = 'triangle';
params.regularizer = 'gradient';
params.solver = 'backslash';
params.maxiter = [];
params.extend = 'warning';
params.tilesize = inf;
params.overlap = 0.20;
params.mask = []; 
params.autoscale = 'on';
params.xscale = 1;
params.yscale = 1;

% was the params struct supplied?
if ~isempty(varargin)
  if isstruct(varargin{1})
    % params is only supplied if its a call from tiled_gridfit
    params = varargin{1};
    if length(varargin)>1
      % check for any overrides
      params = parse_pv_pairs(params,varargin{2:end});
    end
  else
    % check for any overrides of the defaults
    params = parse_pv_pairs(params,varargin);

  end
end

% check the parameters for acceptability
params = check_params(params);

% ensure all of x,y,z,xnodes,ynodes are column vectors,
% also drop any NaN data
x=x(:);
y=y(:);
z=z(:);
k = isnan(x) | isnan(y) | isnan(z);
if any(k)
  x(k)=[];
  y(k)=[];
  z(k)=[];
end
xmin = min(x);
xmax = max(x);
ymin = min(y);
ymax = max(y);

% did they supply a scalar for the nodes?
if length(xnodes)==1
  xnodes = linspace(xmin,xmax,xnodes)';
  xnodes(end) = xmax; % make sure it hits the max
end
if length(ynodes)==1
  ynodes = linspace(ymin,ymax,ynodes)';
  ynodes(end) = ymax; % make sure it hits the max
end

xnodes=xnodes(:);
ynodes=ynodes(:);
dx = diff(xnodes);
dy = diff(ynodes);
nx = length(xnodes);
ny = length(ynodes);
ngrid = nx*ny;

% set the scaling if autoscale was on
if strcmpi(params.autoscale,'on')
  params.xscale = mean(dx);
  params.yscale = mean(dy);
  params.autoscale = 'off';
end

% check to see if any tiling is necessary
if (params.tilesize < max(nx,ny))
  % split it into smaller tiles. compute zgrid and ygrid
  % at the very end if requested
  zgrid = tiled_gridfit(x,y,z,xnodes,ynodes,params);
else
  % its a single tile.
  
  % mask must be either an empty array, or a boolean
  % aray of the same size as the final grid.
  nmask = size(params.mask);
  if ~isempty(params.mask) && ((nmask(2)~=nx) || (nmask(1)~=ny))
    if ((nmask(2)==ny) || (nmask(1)==nx))
      error 'Mask array is probably transposed from proper orientation.'
    else
      error 'Mask array must be the same size as the final grid.'
    end
  end
  if ~isempty(params.mask)
    params.maskflag = 1;
  else
    params.maskflag = 0;
  end

  % default for maxiter?
  if isempty(params.maxiter)
    params.maxiter = min(10000,nx*ny);
  end

  % check lengths of the data
  n = length(x);
  if (length(y)~=n) || (length(z)~=n)
    error 'Data vectors are incompatible in size.'
  end
  if n<3
    error 'Insufficient data for surface estimation.'
  end

  % verify the nodes are distinct
  if any(diff(xnodes)<=0) || any(diff(ynodes)<=0)
    error 'xnodes and ynodes must be monotone increasing'
  end

  % do we need to tweak the first or last node in x or y?
  if xmin<xnodes(1)
    switch params.extend
      case 'always'
        xnodes(1) = xmin;
      case 'warning'
        warning('GRIDFIT:extend',['xnodes(1) was decreased by: ',num2str(xnodes(1)-xmin),', new node = ',num2str(xmin)])
        xnodes(1) = xmin;
      case 'never'
        error(['Some x (',num2str(xmin),') falls below xnodes(1) by: ',num2str(xnodes(1)-xmin)])
    end
  end
  if xmax>xnodes(end)
    switch params.extend
      case 'always'
        xnodes(end) = xmax;
      case 'warning'
        warning('GRIDFIT:extend',['xnodes(end) was increased by: ',num2str(xmax-xnodes(end)),', new node = ',num2str(xmax)])
        xnodes(end) = xmax;
      case 'never'
        error(['Some x (',num2str(xmax),') falls above xnodes(end) by: ',num2str(xmax-xnodes(end))])
    end
  end
  if ymin<ynodes(1)
    switch params.extend
      case 'always'
        ynodes(1) = ymin;
      case 'warning'
        warning('GRIDFIT:extend',['ynodes(1) was decreased by: ',num2str(ynodes(1)-ymin),', new node = ',num2str(ymin)])
        ynodes(1) = ymin;
      case 'never'
        error(['Some y (',num2str(ymin),') falls below ynodes(1) by: ',num2str(ynodes(1)-ymin)])
    end
  end
  if ymax>ynodes(end)
    switch params.extend
      case 'always'
        ynodes(end) = ymax;
      case 'warning'
        warning('GRIDFIT:extend',['ynodes(end) was increased by: ',num2str(ymax-ynodes(end)),', new node = ',num2str(ymax)])
        ynodes(end) = ymax;
      case 'never'
        error(['Some y (',num2str(ymax),') falls above ynodes(end) by: ',num2str(ymax-ynodes(end))])
    end
  end
  
  % determine which cell in the array each point lies in
  [junk,indx] = histc(x,xnodes); %#ok
  [junk,indy] = histc(y,ynodes); %#ok
  % any point falling at the last node is taken to be
  % inside the last cell in x or y.
  k=(indx==nx);
  indx(k)=indx(k)-1;
  k=(indy==ny);
  indy(k)=indy(k)-1;
  ind = indy + ny*(indx-1);
  
  % Do we have a mask to apply?
  if params.maskflag
    % if we do, then we need to ensure that every
    % cell with at least one data point also has at
    % least all of its corners unmasked.
    params.mask(ind) = 1;
    params.mask(ind+1) = 1;
    params.mask(ind+ny) = 1;
    params.mask(ind+ny+1) = 1;
  end
  
  % interpolation equations for each point
  tx = min(1,max(0,(x - xnodes(indx))./dx(indx)));
  ty = min(1,max(0,(y - ynodes(indy))./dy(indy)));
  % Future enhancement: add cubic interpolant
  switch params.interp
    case 'triangle'
      % linear interpolation inside each triangle
      k = (tx > ty);
      L = ones(n,1);
      L(k) = ny;
      
      t1 = min(tx,ty);
      t2 = max(tx,ty);
      A = sparse(repmat((1:n)',1,3),[ind,ind+ny+1,ind+L], ...
        [1-t2,t1,t2-t1],n,ngrid);
      
    case 'nearest'
      % nearest neighbor interpolation in a cell
      k = round(1-ty) + round(1-tx)*ny;
      A = sparse((1:n)',ind+k,ones(n,1),n,ngrid);
      
    case 'bilinear'
      % bilinear interpolation in a cell
      A = sparse(repmat((1:n)',1,4),[ind,ind+1,ind+ny,ind+ny+1], ...
        [(1-tx).*(1-ty), (1-tx).*ty, tx.*(1-ty), tx.*ty], ...
        n,ngrid);
      
  end
  rhs = z;
  
  % do we have relative smoothing parameters?
  if numel(params.smoothness) == 1
    % it was scalar, so treat both dimensions equally
    smoothparam = params.smoothness;
    xyRelativeStiffness = [1;1];
  else
    % It was a vector, so anisotropy reigns.
    % I've already checked that the vector was of length 2
    smoothparam = sqrt(prod(params.smoothness));
    xyRelativeStiffness = params.smoothness(:)./smoothparam;
  end
  
  % Build regularizer. Add del^4 regularizer one day.
  switch params.regularizer
    case 'springs'
      % zero "rest length" springs
      [i,j] = meshgrid(1:nx,1:(ny-1));
      ind = j(:) + ny*(i(:)-1);
      m = nx*(ny-1);
      stiffness = 1./(dy/params.yscale);
      Areg = sparse(repmat((1:m)',1,2),[ind,ind+1], ...
        xyRelativeStiffness(2)*stiffness(j(:))*[-1 1], ...
        m,ngrid);
      
      [i,j] = meshgrid(1:(nx-1),1:ny);
      ind = j(:) + ny*(i(:)-1);
      m = (nx-1)*ny;
      stiffness = 1./(dx/params.xscale);
      Areg = [Areg;sparse(repmat((1:m)',1,2),[ind,ind+ny], ...
        xyRelativeStiffness(1)*stiffness(i(:))*[-1 1],m,ngrid)];
      
      [i,j] = meshgrid(1:(nx-1),1:(ny-1));
      ind = j(:) + ny*(i(:)-1);
      m = (nx-1)*(ny-1);
      stiffness = 1./sqrt((dx(i(:))/params.xscale/xyRelativeStiffness(1)).^2 + ...
        (dy(j(:))/params.yscale/xyRelativeStiffness(2)).^2);
      
      Areg = [Areg;sparse(repmat((1:m)',1,2),[ind,ind+ny+1], ...
        stiffness*[-1 1],m,ngrid)];
      
      Areg = [Areg;sparse(repmat((1:m)',1,2),[ind+1,ind+ny], ...
        stiffness*[-1 1],m,ngrid)];
      
    case {'diffusion' 'laplacian'}
      % thermal diffusion using Laplacian (del^2)
      [i,j] = meshgrid(1:nx,2:(ny-1));
      ind = j(:) + ny*(i(:)-1);
      dy1 = dy(j(:)-1)/params.yscale;
      dy2 = dy(j(:))/params.yscale;
      
      Areg = sparse(repmat(ind,1,3),[ind-1,ind,ind+1], ...
        xyRelativeStiffness(2)*[-2./(dy1.*(dy1+dy2)), ...
        2./(dy1.*dy2), -2./(dy2.*(dy1+dy2))],ngrid,ngrid);
      
      [i,j] = meshgrid(2:(nx-1),1:ny);
      ind = j(:) + ny*(i(:)-1);
      dx1 = dx(i(:)-1)/params.xscale;
      dx2 = dx(i(:))/params.xscale;
      
      Areg = Areg + sparse(repmat(ind,1,3),[ind-ny,ind,ind+ny], ...
        xyRelativeStiffness(1)*[-2./(dx1.*(dx1+dx2)), ...
        2./(dx1.*dx2), -2./(dx2.*(dx1+dx2))],ngrid,ngrid);
      
    case 'gradient'
      % Subtly different from the Laplacian. A point for future
      % enhancement is to do it better for the triangle interpolation
      % case.
      [i,j] = meshgrid(1:nx,2:(ny-1));
      ind = j(:) + ny*(i(:)-1);
      dy1 = dy(j(:)-1)/params.yscale;
      dy2 = dy(j(:))/params.yscale;
      
      Areg = sparse(repmat(ind,1,3),[ind-1,ind,ind+1], ...
        xyRelativeStiffness(2)*[-2./(dy1.*(dy1+dy2)), ...
        2./(dy1.*dy2), -2./(dy2.*(dy1+dy2))],ngrid,ngrid);
      
      [i,j] = meshgrid(2:(nx-1),1:ny);
      ind = j(:) + ny*(i(:)-1);
      dx1 = dx(i(:)-1)/params.xscale;
      dx2 = dx(i(:))/params.xscale;
      
      Areg = [Areg;sparse(repmat(ind,1,3),[ind-ny,ind,ind+ny], ...
        xyRelativeStiffness(1)*[-2./(dx1.*(dx1+dx2)), ...
        2./(dx1.*dx2), -2./(dx2.*(dx1+dx2))],ngrid,ngrid)];
      
  end
  nreg = size(Areg,1);
  
  % Append the regularizer to the interpolation equations,
  % scaling the problem first. Use the 1-norm for speed.
  NA = norm(A,1);
  NR = norm(Areg,1);
  A = [A;Areg*(smoothparam*NA/NR)];
  rhs = [rhs;zeros(nreg,1)];
  % do we have a mask to apply?
  if params.maskflag
    unmasked = find(params.mask);
  end
  % solve the full system, with regularizer attached
  switch params.solver
    case {'\' 'backslash'}
      if params.maskflag
        % there is a mask to use
        zgrid=nan(ny,nx);
        zgrid(unmasked) = A(:,unmasked)\rhs;
      else
        % no mask
        zgrid = reshape(A\rhs,ny,nx);
      end
      
    case 'normal'
      % The normal equations, solved with \. Can be faster
      % for huge numbers of data points, but reasonably
      % sized grids. The regularizer makes A well conditioned
      % so the normal equations are not a terribly bad thing
      % here.
      if params.maskflag
        % there is a mask to use
        Aunmasked = A(:,unmasked);
        zgrid=nan(ny,nx);
        zgrid(unmasked) = (Aunmasked'*Aunmasked)\(Aunmasked'*rhs);
      else
        zgrid = reshape((A'*A)\(A'*rhs),ny,nx);
      end
      
    case 'symmlq'
      % iterative solver - symmlq - requires a symmetric matrix,
      % so use it to solve the normal equations. No preconditioner.
      tol = abs(max(z)-min(z))*1.e-13;
      if params.maskflag
        % there is a mask to use
        zgrid=nan(ny,nx);
        [zgrid(unmasked),flag] = symmlq(A(:,unmasked)'*A(:,unmasked), ...
          A(:,unmasked)'*rhs,tol,params.maxiter);
      else
        [zgrid,flag] = symmlq(A'*A,A'*rhs,tol,params.maxiter);
        zgrid = reshape(zgrid,ny,nx);
      end
      % display a warning if convergence problems
      switch flag
        case 0
          % no problems with convergence
        case 1
          % SYMMLQ iterated MAXIT times but did not converge.
          warning('GRIDFIT:solver',['Symmlq performed ',num2str(params.maxiter), ...
            ' iterations but did not converge.'])
        case 3
          % SYMMLQ stagnated, successive iterates were the same
          warning('GRIDFIT:solver','Symmlq stagnated without apparent convergence.')
        otherwise
          warning('GRIDFIT:solver',['One of the scalar quantities calculated in',...
            ' symmlq was too small or too large to continue computing.'])
      end
      
    case 'lsqr'
      % iterative solver - lsqr. No preconditioner here.
      tol = abs(max(z)-min(z))*1.e-13;
      if params.maskflag
        % there is a mask to use
        zgrid=nan(ny,nx);
        [zgrid(unmasked),flag] = lsqr(A(:,unmasked),rhs,tol,params.maxiter);
      else
        [zgrid,flag] = lsqr(A,rhs,tol,params.maxiter);
        zgrid = reshape(zgrid,ny,nx);
      end
      
      % display a warning if convergence problems
      switch flag
        case 0
          % no problems with convergence
        case 1
          % lsqr iterated MAXIT times but did not converge.
          warning('GRIDFIT:solver',['Lsqr performed ', ...
            num2str(params.maxiter),' iterations but did not converge.'])
        case 3
          % lsqr stagnated, successive iterates were the same
          warning('GRIDFIT:solver','Lsqr stagnated without apparent convergence.')
        case 4
          warning('GRIDFIT:solver',['One of the scalar quantities calculated in',...
            ' LSQR was too small or too large to continue computing.'])
      end
      
  end  % switch params.solver
  
end  % if params.tilesize...

% only generate xgrid and ygrid if requested.
if nargout>1
  [xgrid,ygrid]=meshgrid(xnodes,ynodes);
end

% ============================================
% End of main function - gridfit
% ============================================

% ============================================
% subfunction - parse_pv_pairs
% ============================================
function params=parse_pv_pairs(params,pv_pairs)
% parse_pv_pairs: parses sets of property value pairs, allows defaults
% usage: params=parse_pv_pairs(default_params,pv_pairs)
%
% arguments: (input)
%  default_params - structure, with one field for every potential
%             property/value pair. Each field will contain the default
%             value for that property. If no default is supplied for a
%             given property, then that field must be empty.
%
%  pv_array - cell array of property/value pairs.
%             Case is ignored when comparing properties to the list
%             of field names. Also, any unambiguous shortening of a
%             field/property name is allowed.
%
% arguments: (output)
%  params   - parameter struct that reflects any updated property/value
%             pairs in the pv_array.
%
% Example usage:
% First, set default values for the parameters. Assume we
% have four parameters that we wish to use optionally in
% the function examplefun.
%
%  - 'viscosity', which will have a default value of 1
%  - 'volume', which will default to 1
%  - 'pie' - which will have default value 3.141592653589793
%  - 'description' - a text field, left empty by default
%
% The first argument to examplefun is one which will always be
% supplied.
%
%   function examplefun(dummyarg1,varargin)
%   params.Viscosity = 1;
%   params.Volume = 1;
%   params.Pie = 3.141592653589793
%
%   params.Description = '';
%   params=parse_pv_pairs(params,varargin);
%   params
%
% Use examplefun, overriding the defaults for 'pie', 'viscosity'
% and 'description'. The 'volume' parameter is left at its default.
%
%   examplefun(rand(10),'vis',10,'pie',3,'Description','Hello world')
%
% params = 
%     Viscosity: 10
%        Volume: 1
%           Pie: 3
%   Description: 'Hello world'
%
% Note that capitalization was ignored, and the property 'viscosity'
% was truncated as supplied. Also note that the order the pairs were
% supplied was arbitrary.

npv = length(pv_pairs);
n = npv/2;

if n~=floor(n)
  error 'Property/value pairs must come in PAIRS.'
end
if n<=0
  % just return the defaults
  return
end

if ~isstruct(params)
  error 'No structure for defaults was supplied'
end

% there was at least one pv pair. process any supplied
propnames = fieldnames(params);
lpropnames = lower(propnames);
for i=1:n
  p_i = lower(pv_pairs{2*i-1});
  v_i = pv_pairs{2*i};
  
  ind = strmatch(p_i,lpropnames,'exact');
  if isempty(ind)
    ind = find(strncmp(p_i,lpropnames,length(p_i)));
    if isempty(ind)
      error(['No matching property found for: ',pv_pairs{2*i-1}])
    elseif length(ind)>1
      error(['Ambiguous property name: ',pv_pairs{2*i-1}])
    end
  end
  p_i = propnames{ind};
  
  % override the corresponding default in params
  params = setfield(params,p_i,v_i); %#ok
  
end


% ============================================
% subfunction - check_params
% ============================================
function params = check_params(params)

% check the parameters for acceptability
% smoothness == 1 by default
if isempty(params.smoothness)
  params.smoothness = 1;
else
  if (numel(params.smoothness)>2) || any(params.smoothness<=0)
    error 'Smoothness must be scalar (or length 2 vector), real, finite, and positive.'
  end
end

% regularizer  - must be one of 4 options - the second and
% third are actually synonyms.
valid = {'springs', 'diffusion', 'laplacian', 'gradient'};
if isempty(params.regularizer)
  params.regularizer = 'diffusion';
end
ind = find(strncmpi(params.regularizer,valid,length(params.regularizer)));
if (length(ind)==1)
  params.regularizer = valid{ind};
else
  error(['Invalid regularization method: ',params.regularizer])
end

% interp must be one of:
%    'bilinear', 'nearest', or 'triangle'
% but accept any shortening thereof.
valid = {'bilinear', 'nearest', 'triangle'};
if isempty(params.interp)
  params.interp = 'triangle';
end
ind = find(strncmpi(params.interp,valid,length(params.interp)));
if (length(ind)==1)
  params.interp = valid{ind};
else
  error(['Invalid interpolation method: ',params.interp])
end

% solver must be one of:
%    'backslash', '\', 'symmlq', 'lsqr', or 'normal'
% but accept any shortening thereof.
valid = {'backslash', '\', 'symmlq', 'lsqr', 'normal'};
if isempty(params.solver)
  params.solver = '\';
end
ind = find(strncmpi(params.solver,valid,length(params.solver)));
if (length(ind)==1)
  params.solver = valid{ind};
else
  error(['Invalid solver option: ',params.solver])
end

% extend must be one of:
%    'never', 'warning', 'always'
% but accept any shortening thereof.
valid = {'never', 'warning', 'always'};
if isempty(params.extend)
  params.extend = 'warning';
end
ind = find(strncmpi(params.extend,valid,length(params.extend)));
if (length(ind)==1)
  params.extend = valid{ind};
else
  error(['Invalid extend option: ',params.extend])
end

% tilesize == inf by default
if isempty(params.tilesize)
  params.tilesize = inf;
elseif (length(params.tilesize)>1) || (params.tilesize<3)
  error 'Tilesize must be scalar and > 0.'
end

% overlap == 0.20 by default
if isempty(params.overlap)
  params.overlap = 0.20;
elseif (length(params.overlap)>1) || (params.overlap<0) || (params.overlap>0.5)
  error 'Overlap must be scalar and 0 < overlap < 1.'
end

% ============================================
% subfunction - tiled_gridfit
% ============================================
function zgrid=tiled_gridfit(x,y,z,xnodes,ynodes,params)
% tiled_gridfit: a tiled version of gridfit, continuous across tile boundaries 
% usage: [zgrid,xgrid,ygrid]=tiled_gridfit(x,y,z,xnodes,ynodes,params)
%
% Tiled_gridfit is used when the total grid is far too large
% to model using a single call to gridfit. While gridfit may take
% only a second or so to build a 100x100 grid, a 2000x2000 grid
% will probably not run at all due to memory problems.
%
% Tiles in the grid with insufficient data (<4 points) will be
% filled with NaNs. Avoid use of too small tiles, especially
% if your data has holes in it that may encompass an entire tile.
%
% A mask may also be applied, in which case tiled_gridfit will
% subdivide the mask into tiles. Note that any boolean mask
% provided is assumed to be the size of the complete grid.
%
% Tiled_gridfit may not be fast on huge grids, but it should run
% as long as you use a reasonable tilesize. 8-)

% Note that we have already verified all parameters in check_params

% Matrix elements in a square tile
tilesize = params.tilesize;
% Size of overlap in terms of matrix elements. Overlaps
% of purely zero cause problems, so force at least two
% elements to overlap.
overlap = max(2,floor(tilesize*params.overlap));

% reset the tilesize for each particular tile to be inf, so
% we will never see a recursive call to tiled_gridfit
Tparams = params;
Tparams.tilesize = inf;

nx = length(xnodes);
ny = length(ynodes);
zgrid = zeros(ny,nx);

% linear ramp for the bilinear interpolation
rampfun = inline('(t-t(1))/(t(end)-t(1))','t');

% loop over each tile in the grid
h = waitbar(0,'Relax and have a cup of JAVA. Its my treat.');
warncount = 0;
xtind = 1:min(nx,tilesize);
while ~isempty(xtind) && (xtind(1)<=nx)
  
  xinterp = ones(1,length(xtind));
  if (xtind(1) ~= 1)
    xinterp(1:overlap) = rampfun(xnodes(xtind(1:overlap)));
  end
  if (xtind(end) ~= nx)
    xinterp((end-overlap+1):end) = 1-rampfun(xnodes(xtind((end-overlap+1):end)));
  end
  
  ytind = 1:min(ny,tilesize);
  while ~isempty(ytind) && (ytind(1)<=ny)
    % update the waitbar
    waitbar((xtind(end)-tilesize)/nx + tilesize*ytind(end)/ny/nx)
    
    yinterp = ones(length(ytind),1);
    if (ytind(1) ~= 1)
      yinterp(1:overlap) = rampfun(ynodes(ytind(1:overlap)));
    end
    if (ytind(end) ~= ny)
      yinterp((end-overlap+1):end) = 1-rampfun(ynodes(ytind((end-overlap+1):end)));
    end
    
    % was a mask supplied?
    if ~isempty(params.mask)
      submask = params.mask(ytind,xtind);
      Tparams.mask = submask;
    end
    
    % extract data that lies in this grid tile
    k = (x>=xnodes(xtind(1))) & (x<=xnodes(xtind(end))) & ...
        (y>=ynodes(ytind(1))) & (y<=ynodes(ytind(end)));
    k = find(k);
    
    if length(k)<4
      if warncount == 0
        warning('GRIDFIT:tiling','A tile was too underpopulated to model. Filled with NaNs.')
      end
      warncount = warncount + 1;
      
      % fill this part of the grid with NaNs
      zgrid(ytind,xtind) = NaN;
      
    else
      % build this tile
      zgtile = gridfit(x(k),y(k),z(k),xnodes(xtind),ynodes(ytind),Tparams);
      
      % bilinear interpolation (using an outer product)
      interp_coef = yinterp*xinterp;
      
      % accumulate the tile into the complete grid
      zgrid(ytind,xtind) = zgrid(ytind,xtind) + zgtile.*interp_coef;
      
    end
    
    % step to the next tile in y
    if ytind(end)<ny
      ytind = ytind + tilesize - overlap;
      % are we within overlap elements of the edge of the grid?
      if (ytind(end)+max(3,overlap))>=ny
        % extend this tile to the edge
        ytind = ytind(1):ny;
      end
    else
      ytind = ny+1;
    end
    
  end % while loop over y
  
  % step to the next tile in x
  if xtind(end)<nx
    xtind = xtind + tilesize - overlap;
    % are we within overlap elements of the edge of the grid?
    if (xtind(end)+max(3,overlap))>=nx
      % extend this tile to the edge
      xtind = xtind(1):nx;
    end
  else
    xtind = nx+1;
  end

end % while loop over x

% close down the waitbar
close(h)

if warncount>0
  warning('GRIDFIT:tiling',[num2str(warncount),' tiles were underpopulated & filled with NaNs'])
end
