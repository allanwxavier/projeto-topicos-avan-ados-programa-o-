import * as bcrypt from 'bcrypt';
import { AuthRepository } from '../repositories/auth.repository';

const authRepository = new AuthRepository();

export class RegisterService {
    async execute(name: string, passwordPura: string) {

        const usuarioExistente = await authRepository.findByName(name);
        if (usuarioExistente) {
            throw new Error("Usuário já cadastrado no sistema. ");
        }

        const saltRounds = 10;
        const senhaHasheada = await bcrypt.hash(passwordPura, saltRounds);

        const novoUsuario = await authRepository.create({
            name,
            password: senhaHasheada
        });

        return {
            id: novoUsuario.id,
            name: novoUsuario.name
        };
    }
}