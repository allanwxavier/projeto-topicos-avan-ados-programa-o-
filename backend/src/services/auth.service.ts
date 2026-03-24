import {AuthRepository} from '../repositories/auth.repository';
import crypto from 'crypto';

const authRepository = new AuthRepository();

export class AuthService {
    async login(name: string, password: string) {
        const usuario = await authRepository.findByName(name);

        if (!usuario) return null;

        const senhaCorreta = usuario.password === password;
        if (!senhaCorreta) return null;

        const token = crypto.randomUUID();

        await authRepository.salvarToken(usuario.id, token);

        return {
            id: usuario.id,
            name: usuario.name,
            token
        };

    }
}