clear imst2 imst3 imst4 imst5 imst6 imst7 imst8 imst9 imst10
% imst2=uint8(smooth3(imstack,'gaussian',1));
for i=1:44
imst2(:,:,i)=imresize(uint8(imstack(:,:,i)),0.5);
imst3(:,:,i)=bwareaopen(imst2(:,:,i)>200,10);
imst4(:,:,i)=bwareaopen(imst3(:,:,i),800);
imst5(:,:,i)=imst3(:,:,i).*imcomplement(imst4(:,:,i));
imst6(:,:,i)=bwdist(imcomplement(imst5(:,:,i)));
end
imst7=(single(smooth3(imst6>3,'gaussian',9)>0).*imst6);
imst8=permute(imst7,[3 2 1]);
imst9=imst8;
for j=1:10
for i=1:512
imst9(:,:,i)=imgaussfilt(imst9(:,:,i),1);
end
end
imst10=permute(uint8(imcomplement(smooth3(imst9>0.25,'gaussian',5)>0)),[3 2 1]).*imst2;