import { RegisterService } from '../../src/services/create-user.services';
import { AuthService } from '../../src/services/auth.service';
import { AuthRepository } from '../../src/repositories/auth.repository';
import * as bcrypt from 'bcrypt';

// Mock do repositório
jest.mock('../../src/repositories/auth.repository');

// Mock do JWT
jest.mock('jsonwebtoken', () => ({
  sign: jest.fn().mockReturnValue('mocked_jwt_token_123')
}));

describe('Serviços de Usuário e Autenticação (Testes Unitários)', () => {
  let registerService: RegisterService;
  let authService: AuthService;

  beforeEach(() => {
    jest.clearAllMocks();
    registerService = new RegisterService();
    authService = new AuthService();
  });

  // VALIDAÇÃO 1: Evitar Duplicidade de Usuário
  describe('RegisterService - Cadastro', () => {
    it('deve lançar um erro se o nome de usuário já estiver cadastrado', async () => {
      // Mock do prototype do AuthRepository
      (AuthRepository.prototype.findByName as jest.Mock).mockResolvedValue({
        id: 1,
        name: 'Allan',
        password: 'senha_criptografada'
      });

      // Nota: A mensagem no serviço tem um espaço no final: "Usuário já cadastrado no sistema. "
      await expect(registerService.execute('Allan', 'senha123'))
        .rejects
        .toThrow('Usuário já cadastrado no sistema. ');
    });

    // VALIDAÇÃO 2: Criptografia da Senha
    it('deve hashear a senha do usuário com bcrypt antes de salvar no repositório', async () => {
      (AuthRepository.prototype.findByName as jest.Mock).mockResolvedValue(null);
      (AuthRepository.prototype.create as jest.Mock).mockResolvedValue({
        id: 2,
        name: 'Mayara',
        password: 'senha_criptografada_mock'
      });

      const rawPassword = 'senhaSegura123';
      const result = await registerService.execute('Mayara', rawPassword);

      // Verifica se o método create foi chamado
      expect(AuthRepository.prototype.create).toHaveBeenCalledTimes(1);
      
      // Captura o argumento enviado ao repository.create
      const callArgs = (AuthRepository.prototype.create as jest.Mock).mock.calls[0][0];
      
      // Verifica se a senha gravada NÃO é a senha em texto puro
      expect(callArgs.password).not.toBe(rawPassword);
      
      // Verifica se a senha gravada é compatível com um hash bcrypt (que começa com $2b$ ou $2a$)
      expect(callArgs.password.startsWith('$2b$') || callArgs.password.startsWith('$2a$')).toBe(true);
      
      expect(result).toEqual({ id: 2, name: 'Mayara' });
    });
  });

  describe('AuthService - Login', () => {
    // VALIDAÇÃO 3: Credenciais Inválidas (Usuario Inexistente)
    it('deve retornar null se o usuário não for encontrado no banco', async () => {
      (AuthRepository.prototype.findByName as jest.Mock).mockResolvedValue(null);

      const result = await authService.login('inexistente', 'senha123');
      expect(result).toBeNull();
    });

    it('deve retornar null se a senha estiver incorreta', async () => {
      const senhaHasheada = await bcrypt.hash('senhaCorreta', 10);
      (AuthRepository.prototype.findByName as jest.Mock).mockResolvedValue({
        id: 1,
        name: 'Allan',
        password: senhaHasheada
      });

      const result = await authService.login('Allan', 'senhaIncorreta');
      expect(result).toBeNull();
    });

    // VALIDAÇÃO 4: Sucesso de Autenticação e Token JWT
    it('deve autenticar o usuário e retornar seus dados junto com o Token JWT', async () => {
      const senhaPura = 'senhaCerta';
      const senhaHasheada = await bcrypt.hash(senhaPura, 10);
      (AuthRepository.prototype.findByName as jest.Mock).mockResolvedValue({
        id: 5,
        name: 'Allan',
        password: senhaHasheada
      });

      const result = await authService.login('Allan', senhaPura);

      expect(result).not.toBeNull();
      expect(result?.id).toBe(5);
      expect(result?.name).toBe('Allan');
      expect(result?.token).toBe('mocked_jwt_token_123');
    });
  });
});
