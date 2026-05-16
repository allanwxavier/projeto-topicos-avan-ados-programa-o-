import { createClient } from "redis";

export class redisService {
    private static client: ReturnType<typeof createClient>;

    static async redisConnect() {
        // Formato de objeto (à prova de falhas) em vez de URL
        const client = createClient({
            password: process.env.REDIS_PASSWORD || undefined,
            socket: {
                host: process.env.REDIS_HOST || '127.0.0.1',
                port: parseInt(process.env.REDIS_PORT as string) || 6379
            }
        });
        
        client.on('error', (err) => console.error('[Redis Cache] Erro de conexão:', err));

        await client.connect();
        redisService.client = client;
    }

    static async get(chave: string) {
        return await redisService.client.get(chave);
    }

    static async set(chave: string, valor: string, ttl: number) {
        await redisService.client.set(chave, valor, { EX: ttl });
    }
    
    static async del(chave: string) {
        await redisService.client.del(chave);
        
    }
}