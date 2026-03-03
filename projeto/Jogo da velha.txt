def criar_tabuleiro():
    return [[' ' for _ in range(3)] for _ in range(3)]

def exibir_tabuleiro(tabuleiro):
    print("\n   0   1   2")
    for i, linha in enumerate(tabuleiro):
        print(f"{i}  {' | '.join(linha)}")
        if i < 2:
            print("  ---+---+---")

def verificar_vitoria(tabuleiro, simbolo):
    for i in range(3):
        if all([cel == simbolo for cel in tabuleiro[i]]):
            return True
        if all([tabuleiro[j][i] == simbolo for j in range(3)]):
            return True
    if all([tabuleiro[i][i] == simbolo for i in range(3)]):
        return True
    if all([tabuleiro[i][2 - i] == simbolo for i in range(3)]):
        return True
    return False

def verificar_empate(tabuleiro):
    return all([cel != ' ' for linha in tabuleiro for cel in linha])

def jogada_valida(tabuleiro, linha, coluna):
    return 0 <= linha < 3 and 0 <= coluna < 3 and tabuleiro[linha][coluna] == ' '

def jogar_com_nomes(nome_x, nome_o):
    placar = {"X": 0, "O": 0}
    nomes = {'X': nome_x, 'O': nome_o}

    continuar = True
    while continuar:
        tabuleiro = criar_tabuleiro()
        simbolo_atual = 'X'

        while True:
            exibir_tabuleiro(tabuleiro)
            print(f"\n{nomes[simbolo_atual]} ({simbolo_atual}), é sua vez!")

            try:
                linha = int(input("Escolha a linha (0, 1, 2): "))
                coluna = int(input("Escolha a coluna (0, 1, 2): "))
            except Exception:
                print("Este ambiente não permite entrada interativa. Para jogar, execute o código em um terminal local.")
                return

            if not jogada_valida(tabuleiro, linha, coluna):
                print("Jogada inválida! Tente outra posição.")
                continue

            tabuleiro[linha][coluna] = simbolo_atual

            if verificar_vitoria(tabuleiro, simbolo_atual):
                exibir_tabuleiro(tabuleiro)
                print(f"\nParabéns, {nomes[simbolo_atual]}! Você venceu!")
                placar[simbolo_atual] += 1
                break

            if verificar_empate(tabuleiro):
                exibir_tabuleiro(tabuleiro)
                print("\nA partida terminou em empate!")
                break

            simbolo_atual = 'O' if simbolo_atual == 'X' else 'X'

        print("\nPlacar atual:")
        for simb in placar:
            print(f"{nomes[simb]} ({simb}): {placar[simb]} vitória(s)")

        try:
            continuar = input("Desejam jogar outra partida? (s/n): ").strip().lower() == 's'
        except Exception:
            print("\nEncerrando a partida por limitações de ambiente.")
            break

if __name__ == "__main__":
    try:
        nome_x = input("Digite o nome do Jogador X: ")
        nome_o = input("Digite o nome do Jogador O: ")
        jogar_com_nomes(nome_x, nome_o)
    except Exception:
        print("Este ambiente não permite entrada interativa. Para jogar, execute o código em um terminal local.")
