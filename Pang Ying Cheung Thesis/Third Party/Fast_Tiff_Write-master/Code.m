%% The code to write fast tiff


fTIF = Fast_Tiff_Write(filename);

for k = 1:length(All)
    fTIF.WriteIMG(All(:,:,k)');
end
fTIF.close;
