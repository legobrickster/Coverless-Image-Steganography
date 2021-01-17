clc
clear all;
close all;
[filename, filepath] = uigetfile({'*.jpg; *.png; *.jpeg'},'Select an Image');
A = imread(strcat(filepath, filename));
[icondata,iconcmap]=imread(strcat(filepath, filename));
[filename, filepath] = uigetfile({'*.jpg; *.png; *.jpeg'},'Select an Image');
B = imread(strcat(filepath, filename));
% A=randi([0,255],8,8);
% [c,s]=wavedec2(A,4,'haar');
% A1=appcoef2(c,s,'haar',1);
% A1img = wcodemat(A1,255,'mat',1);
% imagesc(A1img)
% colormap gray(255)
% sum(A1img,'all')
A=rgb2gray(A);
A=imresize(A,[256 256]);

figure
imshow(A)
title('Coverless Image with secret information');
p=zeros(32,1);
p(:,1)=8;
p=p';
A1=mat2cell(A,[p],[p]);

%c=zeros(32,32);
%c=cellfun(@sum,A1);
%[C,S] = cellfun('wavedec2', 'X',A1,'N',2,'value,','haar','Uniform Output',false);
A2=cellfun(@(img) double(img),A1,'UniformOutput',false);
x=double(A2{32,32});

[f,g]=wavedec2(x,2,'haar');
%[c,s]=cellfun(@(img2) wavedec2('X',img2,'N',2,'wname','haar'),A2,'UniformOutput',false);
%[c,s]=cellfun(@(img2) wavedec2('X',img2,'N',2,'wname','haar'),A2,'UniformOutput',false);

wrapper=@(x) wavedec2(x,2,'haar');
[c,s]=cellfun(wrapper,A2,'UniformOutput',false);

wrapper2=@(y) reshape(y,1,[]);
hi=cellfun(wrapper2,c,'UniformOutput',false);
array=reshape(hi,1,[]);
k=1;
for i=1:32
    for j=1:32
        transformed_array(:,k)=cell2mat(c(i,j));
        k=k+1;
    end
end
transformed_array=transformed_array';
sequence=zeros(1024,1);
k=0;
for i=1:1023
    if k==7
        k=0;
    end
    for j=k*8+1:8*k+8
     if transformed_array(i,j)>(1)*transformed_array(i,j+1)
        sequence(i,j)=1;
     else
        sequence(i,j)=0;
     end
    end
    k=k+1;
end
%msg=input('Secret Data: ');
%msg_mat=reshape(msg,[],8);
%t1=fread(fopen('Large Text.txt'));
% t1=input('Enter the secret message: ','s');
% t1=t1';
[filename, filepath] = uigetfile({'*.txt'},'Select an Image');
tic
t1 = fread(fopen(strcat(filepath, filename)));
tt1=uint8(t1);
t=dec2bin(tt1);
t=strcat('0',t);
[rt ct]=size(t);
%[p q]=size(msg_mat);
z=0;
j=1;
format="The data inputs at location %d to %d can be found in the images at block %d, which is at co ordinate (%d,%d), starting at location %d";
for ct=1:rt
    for n=1:1024
        for i=1:48%q=1:p
            match=num2str(sequence(n,[i:i+7]));
            match=match(find(~isspace(match)));
            if t(ct,:)==match%mat2str(msg_mat(q,:))==mat2str(sequence(n,[i:i+7]))
                xl(j)=floor(n/32);
                yl(j)=rem(n,32);
                location(j)=i;
                block(j)=n;
                str=sprintf(format,(ct-1)*8+1,(ct-1)*8+8,n,xl(j),yl(j),i);%(format,(q-1)*8+1,(q-1)*8+8,n,x,y,i)
                %disp(str);
                z=1;
                j=j+1;
            end
            if z==1
                break;
            end
        end
        if z==1
            break;
        end
    end
    z=0;
end

transmitted_data=[block' location']; 
block_lsb=zeros(length(transmitted_data),10);
location_lsb=zeros(length(transmitted_data),6);
block_lsb=dec2bin(transmitted_data(:,1));
location_lsb=dec2bin(transmitted_data(:,2));
%LSB Steganography
B=rgb2gray(B);
B=imresize(B,[256 256]);
C=B;
message_string=strcat(block_lsb,location_lsb);
m=numel(message_string); i=1 ;j=1; o=1; c=1;
[p q]=size(message_string);
for i=1:p
    for j=1:q
        b(c)=message_string(i,j);
        c=c+1;
    end
end
i=1 ;j=1;
while m>0
    B_bin=dec2bin(B(i,j));
    B_bin(8)=b(o);
    B(i,j)=bin2dec(B_bin);
    o=o+1;
    m=m-1;    
    j=j+1;
    if j==256
        j=1;
        i=i+1;
    end
end
% for i=1:rt
%     for j=1:16:241
%         for k=0:9
%          x=block_lsb(i,k+1);
%          B_bin=dec2bin(B(i,j+k));
%          B_bin(8)=x;
%          B(i,j+k)=bin2dec(B_bin);
%         end
%         for k=10:15
%          x=location_lsb(i,k-9);
%          B_bin=dec2bin(B(i,j+k));
%          B_bin(8)=x;
%          B(i,j+k)=bin2dec(B_bin);
%         end
%     end
% end
% j=0;
% for i=1:rt/16
%     for d=1:16
%         if j==256
%             j=0;
%         end
%         u=((d-1)*16)+1;
%         for k=u:u+9
%          j=j+1;   
%          x=block_lsb(i,k);
%          B_bin=dec2bin(B(i,j));
%          B_bin(8)=x;
%          B(i,j)=bin2dec(B_bin);
%         end
%         u=u+10;
%         for k=u:u+5
%          j=j+1;
%          x=location_lsb(i,k-10);
%          B_bin=dec2bin(B(i,j));
%          B_bin(8)=x;
%          B(i,j)=bin2dec(B_bin);
%         end
%     end
% end
% for i=rt:256
%     for j=1:256
%         C(i,j)=C(i,j)+1;
%     end
% end
figure
imshow(B);
title('Cover image with Location Maps hidden using LSB');
% for i=1:rt
%     for j=1:16:241
%         for k=0:9
%          B_bin=dec2bin(B(i,j+k),8);
%          y=B_bin(8);
%          retrieved_block(i,k+1)=y;
%         end
%         for k=10:15
%          B_bin=dec2bin(B(i,j+k),8);
%          y=B_bin(8);
%          retrieved_location(i,k-9)=y;
%         end
%     end
% end
% j=0;
% for i=1:rt/16
%     for d=1:16
%         if j==256
%             j=0;
%         end
%         u=((d-1)*16)+1;
%         for k=u:u+9
%          j=j+1;
%          B_bin=dec2bin(B(i,j),8);
%          y=B_bin(8);
%          retrieved_block(i,k)=y;
%         end
%         u=u+10;
%         for k=u:u+5
%          j=j+1;   
%          B_bin=dec2bin(B(i,j),8);
%          y=B_bin(8);
%          retrieved_location(i,k-10)=y;
%         end
%     end
% end
o=1; i=1; j=1; m=numel(message_string);
while m>0
    B_bin=dec2bin(B(i,j));
    b1(o)=B_bin(8);
    o=o+1;
    m=m-1;    
    j=j+1;
    if j==256
        j=1;
        i=i+1;
    end
end
m=numel(message_string);
for i=1:m/16
    q=(i-1)*16+1;
    retrieved_block(i,:)=b1(q:q+9);
    retrieved_location(i,:)=b1(q+10:q+15);
end
lsb_hidden_transmitted=[bin2dec(retrieved_block) bin2dec(retrieved_location)];

%Decoder


for i=1:length(lsb_hidden_transmitted)
    receiver(i,:)=sequence(lsb_hidden_transmitted(i,1),lsb_hidden_transmitted(i,2):(lsb_hidden_transmitted(i,2)+7));
    received_message(i)=64*receiver(i,2)+32*receiver(i,3)+16*receiver(i,4)+8*receiver(i,5)+4*receiver(i,6)+2*receiver(i,7)+receiver(i,8);
end
message=char(received_message)
m=msgbox(message,'Received Message','custom',icondata,iconcmap);

figure
subplot(2,3,1)
imshow(A)
title('Coverless Image');
subplot(2,3,2)
imshow(C)
title('Cover Image');
subplot(2,3,3)
imshow(B)
title('Cover Image with LSB embedding');
subplot(2,3,4)
imhist(A)
title('Histogram of the Coverless Image');
xlabel('Pixel Instensity')
ylabel('Number of pixels');
subplot(2,3,5)
imhist(C)
title('Histogram of the Cover Image');
xlabel('Pixel Instensity')
ylabel('Number of pixels');
subplot(2,3,6)
imhist(B);
title('Histogram of the LSB embedded Cover Image');
xlabel('Pixel Instensity')
ylabel('Number of pixels');
sgtitle('Coverless Image Steganography with Location map embedded using LSB technique');
[peaksnr, snr] = psnr(B, C);
[ssimval,ssimmap] = ssim(B,C);
toc
%receiver=receiver(find(~isspace(receiver)));
