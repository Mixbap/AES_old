function [ Encrypted_Data ] = ccm_encrypted_aes( Input_Data, Key_AES )

Encrypted_Data = xor(Input_Data, Key_AES);

end

