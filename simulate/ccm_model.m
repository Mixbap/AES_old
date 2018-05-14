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
%data signal
fdata = fopen('input_data.dat','wb');
fprintf(fdata, '%d\n', ceil(Data_length/8));
for i = 1 : length(Data_Payload)
switch (mod(i, 8))
    case 0
        fprintf(fdata, '%d\n', Data_Payload(i - 7));
    case 1
       fprintf(fdata, '%d', Data_Payload( (i - mod(i,8)) + 8 )); 
    case 2
       fprintf(fdata, '%d', Data_Payload( (i - mod(i,8)) + 7 ));
    case 3
       fprintf(fdata, '%d', Data_Payload( (i - mod(i,8)) + 6 ));
    case 4
       fprintf(fdata, '%d', Data_Payload( (i - mod(i,8)) + 5 )); 
    case 5
       fprintf(fdata, '%d', Data_Payload( (i - mod(i,8)) + 4 ));
    case 6
       fprintf(fdata, '%d', Data_Payload( (i - mod(i,8)) + 3 ));
    case 7
       fprintf(fdata, '%d', Data_Payload( (i - mod(i,8)) + 2 ));
end

end    
fclose(fdata);

%enable signal
enable = 1;
i = 0;
while (i < ceil(Data_length/8)-1)
    n = randi([0 1], 1, 1);
    if (n)
        i = i + 1;
    end
    enable = [enable n];
end

fenable = fopen('input_enable.dat','wb');
fprintf(fenable, '%d\n', length(enable));
fprintf(fenable, '%d\n', enable);
fclose(fenable);

%encrypted data signal
fencrypt = fopen('encrypt_data_matlab.dat','wb');
fprintf(fencrypt, '%d\n', length(Encrypted_Data)/8);
for i = 1 : length(Encrypted_Data)
switch (mod(i, 8))
    case 0
        fprintf(fencrypt, '%d\n', Encrypted_Data(i - 7));
    case 1
       fprintf(fencrypt, '%d', Encrypted_Data( (i - mod(i,8)) + 8 )); 
    case 2
       fprintf(fencrypt, '%d', Encrypted_Data( (i - mod(i,8)) + 7 ));
    case 3
       fprintf(fencrypt, '%d', Encrypted_Data( (i - mod(i,8)) + 6 ));
    case 4
       fprintf(fencrypt, '%d', Encrypted_Data( (i - mod(i,8)) + 5 )); 
    case 5
       fprintf(fencrypt, '%d', Encrypted_Data( (i - mod(i,8)) + 4 ));
    case 6
       fprintf(fencrypt, '%d', Encrypted_Data( (i - mod(i,8)) + 3 ));
    case 7
       fprintf(fencrypt, '%d', Encrypted_Data( (i - mod(i,8)) + 2 ));
end
end
fclose(fencrypt);



