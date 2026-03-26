import {AuthRepository} from '../repositories/auth.repository';
import { sign } from 'jsonwebtoken';
import * as bcrypt from 'bcrypt';
import 'dotenv/config';

const authRepository = new AuthRepository();
const JWT_SECRET = process.env.JWT_SECRET as string;

export class AuthService {
    async login(name: string, passwordAttemp: string) {
        const usuario = await authRepository.findByName(name);

        if (!usuario) return null;

        const senhaCorreta = await bcrypt.compare(passwordAttemp, usuario.password);
        if (!senhaCorreta) return null;

        const token = sign(
            {id: usuario.id, name: usuario.name},
            JWT_SECRET,
            {expiresIn: '1d'}
        );

        return {
            id: usuario.id,
            name: usuario.name,
            token
        };

    }
}