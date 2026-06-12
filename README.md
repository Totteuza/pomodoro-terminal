# Pomodoro Timer — PowerShell

Timer Pomodoro para terminal, sem dependências externas.

## Uso

```powershell
.\pomodoro.ps1
```

Parâmetros opcionais:

| Parâmetro    | Padrão | Descrição                        |
|--------------|--------|----------------------------------|
| `-FocusMin`  | 25     | Duração do bloco de foco (min)   |
| `-ShortMin`  | 5      | Duração da pausa curta (min)     |
| `-LongMin`   | 15     | Duração da pausa longa (min)     |
| `-Rounds`    | 4      | Rodadas até a pausa longa        |

Exemplo com configuração personalizada:

```powershell
.\pomodoro.ps1 -FocusMin 50 -ShortMin 10 -LongMin 20 -Rounds 3
```

## Teclas durante o timer

| Tecla | Ação              |
|-------|-------------------|
| `P`   | Pausar / continuar |
| `S`   | Pular sessão      |
| `Q`   | Sair              |

## Histórico

As sessões concluídas são salvas automaticamente em `historico.txt` na mesma pasta do script.
