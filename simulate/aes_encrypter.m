script
clear

%--------------------------TEST AES----------------------------------------
Input_hex = ['00' '44' '88' 'cc'
             '11' '55' '99' 'dd'
             '22' '66' 'aa' 'ee'
             '33' '77' 'bb' 'ff'];

Input_data = aes_debug_hex_to_bin_array(Input_hex);

Key_AES_hex = ['00' '04' '08' '0c'
               '01' '05' '09' '0d'
               '02' '06' '0a' '0e'
               '03' '07' '0b' '0f'];

Key_AES = aes_debug_hex_to_bin_array(Key_AES_hex);


%--------------------------KeyExpension------------------------------------
RoundKey = KeyExpension( Key_AES );

% Debug
% RoundKey_hex = '';
% for j = 1:176
%     RoundKey_hex_val = aes_array2hex(RoundKey((8*(j-1))+1 : 8*j));
%     RoundKey_hex = [RoundKey_hex ' ' RoundKey_hex_val];
% end
%--------------------------AddRoundKey-------------------------------------
RoundData = AddRoundKey( Input_data, Key_AES );

% RoundData_hex = aes_array128_to_hex(RoundData);%debug
%--------------------------------------------------------------------------
%-------------------1-9 ROUNDS---------------------------------------------
%--------------------------------------------------------------------------
for Round = 0:8
%---------------------------SubBytes---------------------------------------
for X = 1:4
    for Y = 1:4
        byte = RoundData(X, (8*(Y-1))+1 : 8*Y);
        RoundData(X, (8*(Y-1))+1 : 8*Y) = SubBytes(byte);
    end
end

% RoundData_hex = aes_array128_to_hex(RoundData);%debug

%--------------------------ShiftRows---------------------------------------
RoundData = ShiftRows( RoundData );

% RoundData_hex = aes_array128_to_hex(RoundData);%debug
%--------------------------MixColumns--------------------------------------
for i = 1:4
    
    RoundData_stolb = [RoundData(1,(8*(i-1))+1 : 8*i) RoundData(2,(8*(i-1))+1 : 8*i) RoundData(3,(8*(i-1))+1 : 8*i) RoundData(4,(8*(i-1))+1 : 8*i)];
    
%     % Debug
%     RoundData_stolb_hex = '';
%     for j = 1:4
%         RoundData_stolb_hex_val = aes_array2hex(RoundData_stolb((8*(j-1))+1 : 8*j));
%         RoundData_stolb_hex = [RoundData_stolb_hex ' ' RoundData_stolb_hex_val];
%     end
    
   
    Data = MixColumns(RoundData_stolb);
    
%     % Debug
%     Data_hex = '';
%     for j = 1:4
%         Data_hex_val = aes_array2hex(Data((8*(j-1))+1 : 8*j));
%         Data_hex = [Data_hex ' ' Data_hex_val];
%     end
%     
  
    
    for m = 1:4  
        RoundData_m(m, (8*(i-1))+1 : 8*i) = Data((8*(m-1))+1 : 8*m);
    end
        
end
RoundData = RoundData_m;

% RoundData_hex = aes_array128_to_hex(RoundData);%debug
%--------------------------AddRoundKey-------------------------------------
Key_N_str = RoundKey((128*Round+128)+1 : 128*(Round+1)+128);

N = 0;
X = 1;
K = 0;
for i = 1:128
   
    %---��������� ������� ������ �� ������---
    N = N + 1;
    
    if N<9 
        Key_N(X,N+K) = Key_N_str(i);
    else
        X = X + 1;
        if X>4
            K = K + 8;
            X = 1;
            N = 1;
        end
        N = 1;
        Key_N(X,N+K) = Key_N_str(i);
    end
end

RoundData = AddRoundKey( RoundData, Key_N );

% RoundData_hex = aes_array128_to_hex(RoundData);%debug
end

%--------------------------------------------------------------------------
%----------------------------10 ROUND--------------------------------------
%--------------------------------------------------------------------------

%---------------------------SubBytes---------------------------------------
for X = 1:4
    for Y = 1:4
        byte = RoundData(X, (8*(Y-1))+1 : 8*Y);
        RoundData(X, (8*(Y-1))+1 : 8*Y) = SubBytes(byte);
    end
end

% RoundData_hex = aes_array128_to_hex(RoundData);%debug
%--------------------------ShiftRows---------------------------------------
RoundData = ShiftRows( RoundData );

% RoundData_hex = aes_array128_to_hex(RoundData);%debug
%--------------------------AddRoundKey-------------------------------------
Key_N_str = RoundKey((128*9+128)+1 : 128*(9+1)+128);

N = 0;
X = 1;
K = 0;
for i = 1:128
   
    %---��������� ������� ������ �� ������---
    N = N + 1;
    
    if N<9 
        Key_N(X,N+K) = Key_N_str(i);
    else
        X = X + 1;
        if X>4
            K = K + 8;
            X = 1;
            N = 1;
        end
        N = 1;
        Key_N(X,N+K) = Key_N_str(i);
    end
end

Encrypted_Data = AddRoundKey( RoundData, Key_N );

% Encrypted_Data_test = ['69' '6a' 'd8' '70'
%                        'c4' '7b' 'cd' 'b4' 
%                        'e0' '04' 'b7' 'c5'
%                        'd8' '30' '80' '5a'];

Encrypted_Data_hex = aes_array128_to_hex(Encrypted_Data);%debug

