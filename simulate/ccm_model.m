script
clear

%---Input Parameters-------------------------------------------------------
ERROR = 0; %количество ошибочных передач
Test_value = 1000; %количество тестовых пусков
Data_length = 230; %размер данных
Header_length = 16; %размер заголовка (<128)


for N = 1:Test_value

%---Initialization------------------------------------------------------    
 [Nonce, Intial_Vector, Data_Payload, Section_value, Key_Vector, Header_TB] = ccm_initialization(Header_length, Data_length);   

%--------Create MIC------------------------------------------------------
MIC = ccm_create_mic(Header_TB, Intial_Vector, Section_value, Data_Payload, Key_Vector);

%------Create Encryption Data------------------------------------------------------------------------
for k = 0:(Section_value - 1)
    
    Counter = ccm_create_counter(k+1, Nonce);
    
    Encrypted_Counter = ccm_encrypted_aes(Counter, Key_Vector); %зашифровали Counter
    Encrypted_Data(128*k + 1 : 128*k + 128) = xor(Encrypted_Counter, Data_Payload(128*k + 1 : 128*k + 128)); %xor данных с AES Counter
    
end


%-------Create Encryption MIC-------------------------------------
MIC(65:128) = 0; %заполнение MIC нулями
Counter = ccm_create_counter(0, Nonce);

Encrypted_Counter_MIC = ccm_encrypted_aes(Counter, Key_Vector); %AES Counter MIC
Encrypted_MIC = xor(MIC, Encrypted_Counter_MIC); %зашифровали MIC


%---Create full data section-----------------------------------------------
Full_Data_section = [Header_TB Encrypted_Data Encrypted_MIC];

%--------------------------------------------------------------------------
%------------------------Decrypted-----------------------------------------
%--------------------------Data--------------------------------------------
%--------------------------------------------------------------------------
%--------------------------------------------------------------------------


%---Decrypted Data---------------------------------------------------------
for k = 0:(Section_value - 1)
    
    Counter = ccm_create_counter(k+1, Nonce);
    
    Encrypted_Counter = ccm_encrypted_aes(Counter, Key_Vector); %зашифровали Counter
    Decrypted_Data(128*k + 1 : 128*k + 128) = xor(Encrypted_Counter, Encrypted_Data(128*k + 1 : 128*k + 128)); %xor данных с AES Counter
    
end

%---Decrypted MIC-------------------------------------------------------
Decrypted_MIC = ccm_create_mic(Header_TB, Intial_Vector, Section_value, Decrypted_Data, Key_Vector);


%-------Create Encryption Decrypted_MIC-------------------------------------
Decrypted_MIC(65:128) = 0; %заполнение MIC нулями
Counter = ccm_create_counter(0, Nonce);

Encrypted_Counter_MIC = ccm_encrypted_aes(Counter, Key_Vector); %AES Counter MIC
Encrypted_Decrypted_MIC = xor(Decrypted_MIC, Encrypted_Counter_MIC); %зашифровали MIC
 

% %---Add random error bit MIC-----------------------------------------------
% ERROR_bit = randi([1 128], 1, 1);
% Encrypted_Decrypted_MIC(ERROR_bit) = 1;

%---Search error------------------------------------------------------
if Encrypted_Decrypted_MIC == Encrypted_MIC
    
else
   ERROR = ERROR + 1; 
end


end

%----Create output file data (.dat)---------------------------------------------------
fdata = fopen('input_data.dat','wb');
fwrite(fdata, Data_Payload, 'double');
fclose(fdata);

% fdata = fopen('data_length.dat','wb');
% fwrite(fdata, Data_length, 'double');
% fclose(fdata);

% fdata = fopen('output_data.dat','r');
% B = fread(fdata, 256, 'double');
% fclose(fdata);



