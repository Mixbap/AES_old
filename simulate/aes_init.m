function [ Input_data, Key_AES ] = aes_init( Input_data_str )
%Преобразование массива данных в матрицу, создание ключа 

%---Key_AES----------------------------------------------------------------
N = 0;
X = 1;
K = 0;
for i = 1:128
    %---Заполнение строки ключа---
    if mod(i,2)
        Key_AES_str(i) = 1;
    else
        Key_AES_str(i) = 0;
    end
    
    %---Получение матрицы ключа из строки---
    N = N + 1;
    
    if N<9 
        Key_AES(X,N+K) = Key_AES_str(i);
    else
        X = X + 1;
        if X>4
            K = K + 8;
            X = 1;
            N = 1;
        end
        N = 1;
        Key_AES(X,N+K) = Key_AES_str(i);
    end
end

%---Input data-------------------------------------------------------------
N = 0;
X = 1;
K = 0;
for i = 1:128
    %---Заполнение строки данных---
%     if mod(i,2)
%         Input_data_str(i) = 1;
%     else
%         Input_data_str(i) = 0;
%     end

    
    %---Получение матрицы данных из строки---
    N = N + 1;
    
    if N<9 
        Input_data(X,N+K) = Input_data_str(i);
    else
        X = X + 1;
        if X>4
            K = K + 8;
            X = 1;
            N = 1;
        end
        N = 1;
        Input_data(X,N+K) = Input_data_str(i);
    end
    
    
end



end



