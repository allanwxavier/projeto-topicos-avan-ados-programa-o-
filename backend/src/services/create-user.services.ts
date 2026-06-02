import * as bcrypt from 'bcrypt';
import { AuthRepository } from '../repositories/auth.repository';

const authRepository = new AuthRepository();

export class RegisterService {
    async execute(name: string, passwordPura: string, matricula?: string, cargo?: string, setor?: string) {

        const usuarioExistente = await authRepository.findByName(name);
        if (usuarioExistente) {
            throw new Error("Usuário já cadastrado no sistema. ");
        }

        const saltRounds = 10;
        const senhaHasheada = await bcrypt.hash(passwordPura, saltRounds);

        const novoUsuario = await authRepository.create({
            name,
            password: senhaHasheada,
            matricula,
            cargo,
            setor
        });

        return {
            id: novoUsuario.id,
            name: novoUsuario.name
        };
    }
}