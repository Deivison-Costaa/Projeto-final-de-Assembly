.686
.model flat, stdcall
option casemap :none


include \masm32\include\windows.inc
include \masm32\include\masm32.inc
include \masm32\include\kernel32.inc
include \masm32\include\msvcrt.inc
includelib \masm32\lib\kernel32.lib
includelib \masm32\lib\msvcrt.lib
includelib \masm32\lib\masm32.lib



.data
    arquivo_Entrada db 50 dup(0)
    arquivo_Saida db 50 dup(0)

    mensagem_Entrada db "Digite o nome da imagem que vai ser censurada: ", 0
    mensagem_Saida db "Digite o nome da imagem de saida: ", 0
    mensagem_CoordenadaX db "Coordenada x: ", 0
    mensagem_Coordenaday db "Coordenada y: ", 0
    mensagem_Largura db "Largura: ", 0
    mensagem_Altura db "Altura: ", 0
    entrada_inteiros db 10 dup(0)

    handle_ArqEntrada dd 0
    handle_ArqSaida dd 0
    input_Handle dd 0
    output_Handle dd 0
    console_count dd 0 
    control_count_01 dd 0


    bytes_lidos dd 0
    bytes_escritos dd 0
    contador dd 0
    vazio db 0
    buffer db 6840 dup(0)
    buffer_01 dd 0
    buffer_02 dd 0
    tamanho_total dd 0
    contadorTotal dd 0
    contadorLinhas dd 0
    largura_imagem dd 0
    largura_imagem_bytes dd 0
    coordenada_x dd 0
    coordenada_y dd 0
    larguraTarja dd 0
    alturaTarja dd 0

    

.code
censurar:
        push ebp
        mov ebp, esp
        sub esp, 8
            
        mov esi, DWORD PTR[ebp+16]


        mov eax, DWORD PTR[ebp+12]
        mov DWORD PTR[ebp-4], eax
        mov ecx, DWORD PTR[ebp+8]
        mov DWORD PTR[ebp-8], ecx

        mov ecx, DWORD PTR[ebp-4]
        mov eax, 3
        mul ecx
        mov ecx, eax

        mov ebx, DWORD PTR[ebp-4]
        add ebx, DWORD PTR[ebp-8]
        mov eax, 3
        mul ebx
        mov ebx, eax

        cmp DWORD PTR[ebp-4], ebx
        jle censuraFinal
        jmp soma1
            
        censuraFinal:
            xor eax, eax
            mov [esi + ecx], al
            mov [esi + ecx+1], al
            mov [esi + ecx+2], al
        soma1:
            add ecx, 1
            
            cmp ecx, ebx
            jbe censuraFinal
        
        retorno:
            mov esp, ebp
            pop ebp
            ret 8
    
inicio:
    ;------------------
    ;Inicio dos Handles
    ;------------------
    
    invoke GetStdHandle, STD_INPUT_HANDLE
    mov input_Handle, eax
    invoke GetStdHandle, STD_OUTPUT_HANDLE
    mov output_Handle, eax

    ;------------------
    ;nome dos arquivos
    ;------------------

    invoke WriteConsole, output_Handle, addr mensagem_Entrada, sizeof mensagem_Entrada, addr console_count, NULL
    invoke ReadConsole, input_Handle, addr arquivo_Entrada, sizeof arquivo_Entrada, addr console_count, NULL
    
    mov esi, offset arquivo_Entrada
proximo_01:
    mov al, [esi]
    inc esi
    cmp al, 13
    jne proximo_01
    dec esi 
    xor al, al 
    mov [esi], al

    invoke WriteConsole, output_Handle, addr mensagem_Saida, sizeof mensagem_Saida, addr console_count, NULL
    invoke ReadConsole, input_Handle, addr arquivo_Saida, sizeof arquivo_Saida, addr console_count, NULL
    
    mov esi, offset arquivo_Saida
proximo_02:
    mov al, [esi]
    inc esi
    cmp al, 13
    jne proximo_02
    dec esi 
    xor al, al 
    mov [esi], al


    ;------------------
    ;Valores das coordenadas
    ;------------------


    invoke WriteConsole, output_Handle, addr mensagem_CoordenadaX, sizeof mensagem_CoordenadaX, addr console_count, NULL
    invoke ReadConsole, input_Handle, addr entrada_inteiros, sizeof entrada_inteiros, addr console_count, NULL

    mov esi, offset entrada_inteiros
proximo_03:
    mov al, [esi]
    inc esi
    cmp al, 48
    jl terminar_03
    cmp al, 58
    jl proximo_03
terminar_03:
    dec esi
    xor al, al
    mov [esi], al

    invoke atodw, addr entrada_inteiros
    mov coordenada_x, eax




    invoke WriteConsole, output_Handle, addr mensagem_Coordenaday, sizeof mensagem_Coordenaday, addr console_count, NULL
    invoke ReadConsole, input_Handle, addr entrada_inteiros, sizeof entrada_inteiros, addr console_count, NULL

    mov esi, offset entrada_inteiros
proximo_04:
    mov al, [esi]
    inc esi
    cmp al, 48
    jl terminar_04
    cmp al, 58
    jl proximo_04
terminar_04:
    dec esi
    xor al, al
    mov [esi], al

    invoke atodw, addr entrada_inteiros
    mov coordenada_y, eax




    invoke WriteConsole, output_Handle, addr mensagem_Largura, sizeof mensagem_Largura, addr console_count, NULL
    invoke ReadConsole, input_Handle, addr entrada_inteiros, sizeof entrada_inteiros, addr console_count, NULL

    mov esi, offset entrada_inteiros
proximo_05:
    mov al, [esi]
    inc esi
    cmp al, 48
    jl terminar_05
    cmp al, 58
    jl proximo_05
terminar_05:
    dec esi
    xor al, al
    mov [esi], al

    invoke atodw, addr entrada_inteiros
    mov larguraTarja, eax




    invoke WriteConsole, output_Handle, addr mensagem_Altura, sizeof mensagem_Altura, addr console_count, NULL
    invoke ReadConsole, input_Handle, addr entrada_inteiros, sizeof entrada_inteiros, addr console_count, NULL

    mov esi, offset entrada_inteiros
proximo_06:
    mov al, [esi]
    inc esi
    cmp al, 48
    jl terminar_06
    cmp al, 58
    jl proximo_06
terminar_06:
    dec esi
    xor al, al
    mov [esi], al

    invoke atodw, addr entrada_inteiros
    mov alturaTarja, eax

    ;------------------
    ;iniciacao dos arquivos
    ;------------------

    invoke CreateFile, addr arquivo_Entrada, GENERIC_READ, 0, NULL, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, NULL
    mov handle_ArqEntrada, eax
    invoke CreateFile, addr arquivo_Saida, GENERIC_WRITE, 0, NULL, CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL, NULL
    mov handle_ArqSaida, eax

    
    ;------------------
    ;Leitura dos bytes iniciais
    ;------------------

    invoke ReadFile, handle_ArqEntrada, addr buffer, 18, bytes_lidos, NULL
    invoke WriteFile, handle_ArqSaida, addr buffer, 18, bytes_escritos, NULL

    invoke ReadFile, handle_ArqEntrada, addr buffer_01, 4, bytes_lidos, NULL
    invoke WriteFile, handle_ArqSaida, addr buffer_01, 4, bytes_escritos, NULL

    invoke ReadFile, handle_ArqEntrada, addr buffer_02, 4, bytes_lidos, NULL
    invoke WriteFile, handle_ArqSaida, addr buffer_02, 4, bytes_escritos, NULL

    invoke ReadFile, handle_ArqEntrada, addr buffer, 28, bytes_lidos, NULL
    invoke WriteFile, handle_ArqSaida, addr buffer, 28, bytes_escritos, NULL


    mov ecx, buffer_01[0]
    mov largura_imagem, ecx
    mov eax, 3
    mul largura_imagem
    mov largura_imagem_bytes, eax
    xor edx, edx
    xor eax, eax
    mov edx, ecx
    mov ecx, buffer_02[0]
    mov eax, ecx
    mul edx
    mov edx, eax
    mov eax, 3
    mul edx
    add eax, 54
    mov tamanho_total, eax

    xor eax, eax
    mov contadorLinhas, eax

    xor ecx, ecx
    mov ecx, 54
    mov contadorTotal, ecx
    ;------------------
    ;Loop principal
    ;------------------
    
loop_01:
    mov ecx, largura_imagem_bytes
    add contadorTotal, ecx
    
    invoke ReadFile, handle_ArqEntrada, addr buffer, largura_imagem_bytes, bytes_lidos, NULL
    mov eax, 1
    add contadorLinhas, eax
    
    mov eax, coordenada_y
    cmp eax, contadorLinhas
    jbe comCensura
    
    jmp semCensura
    semCensura:
        invoke WriteFile, handle_ArqSaida, addr buffer, largura_imagem_bytes, bytes_escritos, NULL

        mov eax, tamanho_total
        cmp eax, contadorTotal
        jle fimDoArquivo
        jmp loop_01
    comCensura:
        mov ecx, alturaTarja
        add ecx, coordenada_y
        cmp ecx, contadorLinhas
        jb semCensura

        push offset buffer
        push coordenada_x
        push larguraTarja
        call censurar
        invoke WriteFile, handle_ArqSaida, addr buffer, largura_imagem_bytes, bytes_escritos, NULL
        mov eax, tamanho_total
        cmp eax, contadorTotal
        jle fimDoArquivo
        jmp loop_01


fimDoArquivo:    
    invoke CloseHandle, handle_ArqEntrada
    invoke CloseHandle, handle_ArqSaida
    invoke ExitProcess, 0

end inicio