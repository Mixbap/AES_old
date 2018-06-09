script
clear

%--------------------------TEST AES----------------------------------------
% Input_hex = ['00' '44' '88' 'cc'
%              '11' '55' '99' 'dd'
%              '22' '66' 'aa' 'ee'
%              '33' '77' 'bb' 'ff'];
% 
% Input_data = aes_debug_hex_to_bin_array(Input_hex);
% 
% Key_AES_hex = ['00' '04' '08' '0c'
%                '01' '05' '09' '0d'
%                '02' '06' '0a' '0e'
%                '03' '07' '0b' '0f'];
% 
% Key_AES = aes_debug_hex_to_bin_array(Key_AES_hex);

%----------Read key--------------------------------------------------------
fdata_key = fopen('aes_key.dat', 'r');

Key_AES_length = fscanf(fdata_key, '%d', 1);

n = 1;
A = fscanf(fdata_key, '%c', 1);
for i = 1 : Key_AES_length
    for j = 1:8
        Key_AES_str = fscanf(fdata_key, '%c', 1);
        Key_AES(n) = str2num(Key_AES_str);
        n = n + 1;
    end
    A = fscanf(fdata_key, '%c', 1);
end
Key_AES = aes_array_to_matrix(Key_AES);
fclose(fdata_key);
clear A

%----------Read input data-------------------------------------------------
fdata_in = fopen('aes_input_data.dat', 'r');

Input_data_length = fscanf(fdata_in, '%d', 1);

n = 1;
A = fscanf(fdata_in, '%c', 1);
for i = 1 : Input_data_length
    for j = 1:8
        Input_data_full_str = fscanf(fdata_in, '%c', 1);
        Input_data_full(n) = str2num(Input_data_full_str);
        n = n + 1;
    end
    A = fscanf(fdata_in, '%c', 1);
end
fclose(fdata_in);
clear A

for section = 0 : Input_data_length/16 - 1
    
Input_data = aes_array_to_matrix(Input_data_full(128*section + 1 : 128*(section + 1)));


%--------------------------KeyExpension------------------------------------
RoundKey = KeyExpension( Key_AES );

%--------------------------AddRoundKey-------------------------------------
RoundData = AddRoundKey( Input_data, Key_AES );

%--------------------------------------------------------------------------
%-------------------1-10 ROUNDS---------------------------------------------
%--------------------------------------------------------------------------
for Round = 0:9
%---------------------------SubBytes---------------------------------------
for X = 1:4
    for Y = 1:4
        byte = RoundData(X, (8*(Y-1))+1 : 8*Y);
        RoundData(X, (8*(Y-1))+1 : 8*Y) = SubBytes(byte);
    end
end

%--------------------------ShiftRows---------------------------------------
RoundData = ShiftRows( RoundData );

%--------------------------MixColumns--------------------------------------
if (Round < 9)

for i = 1:4
    
    RoundData_colums = [RoundData(1,(8*(i-1))+1 : 8*i) RoundData(2,(8*(i-1))+1 : 8*i) RoundData(3,(8*(i-1))+1 : 8*i) RoundData(4,(8*(i-1))+1 : 8*i)];
   
    Data = MixColumns(RoundData_colums);
       
    for m = 1:4  
        RoundData_m(m, (8*(i-1))+1 : 8*i) = Data((8*(m-1))+1 : 8*m);
    end
        
end
RoundData = RoundData_m;

end

%--------------------------AddRoundKey-------------------------------------
Key_N_str = RoundKey((128*Round+128)+1 : 128*(Round+1)+128);

Key_N = aes_array_to_matrix(Key_N_str);

RoundData = AddRoundKey( RoundData, Key_N );

end

Encrypted_Data = RoundData;

Encrypted_Data_hex = aes_array128_to_hex(Encrypted_Data);%debug

Enc0 = [Encrypted_Data(1,1:8) Encrypted_Data(2,1:8) Encrypted_Data(3,1:8) Encrypted_Data(4,1:8)];
Enc1 = [Encrypted_Data(1,9:16) Encrypted_Data(2,9:16) Encrypted_Data(3,9:16) Encrypted_Data(4,9:16)];
Enc2 = [Encrypted_Data(1,17:24) Encrypted_Data(2,17:24) Encrypted_Data(3,17:24) Encrypted_Data(4,17:24)];
Enc3 = [Encrypted_Data(1,25:32) Encrypted_Data(2,25:32) Encrypted_Data(3,25:32) Encrypted_Data(4,25:32)];

Encrypted_Data_m = [Enc0 Enc1 Enc2 Enc3];

if (section == 0)
    Encrypted_Data_full = Encrypted_Data_m;
else
    Encrypted_Data_full = [Encrypted_Data_full Encrypted_Data_m];
end

end

%-----------Write data-----------------------------------------------------
fdata_out = fopen('aes_output_data.dat', 'wb');
fprintf(fdata_out, '%d\n', Input_data_length);
for i = 1 : 8*Input_data_length
   switch (mod(i, 8))
    case 0
        fprintf(fdata_out, '%d\n', Encrypted_Data_full(i - 7));
    case 1
       fprintf(fdata_out, '%d', Encrypted_Data_full( (i - mod(i,8)) + 8 )); 
    case 2
       fprintf(fdata_out, '%d', Encrypted_Data_full( (i - mod(i,8)) + 7 ));
    case 3
       fprintf(fdata_out, '%d', Encrypted_Data_full( (i - mod(i,8)) + 6 ));
    case 4
       fprintf(fdata_out, '%d', Encrypted_Data_full( (i - mod(i,8)) + 5 )); 
    case 5
       fprintf(fdata_out, '%d', Encrypted_Data_full( (i - mod(i,8)) + 4 ));
    case 6
       fprintf(fdata_out, '%d', Encrypted_Data_full( (i - mod(i,8)) + 3 ));
    case 7
       fprintf(fdata_out, '%d', Encrypted_Data_full( (i - mod(i,8)) + 2 ));
    end 
end

fclose(fdata_out);





