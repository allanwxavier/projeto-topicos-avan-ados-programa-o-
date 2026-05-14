import { createClient,  } from "redis";

export class redisService{
    private static client: ReturnType<typeof createClient>;

    static async redisConnect(){

        const client = createClient({
            url:
            `redis://:${process.env.REDIS_PASSWORD}@${process.env.REDIS_HOST}:${process.env.REDIS_PORT}`
        });
        client.on('error', (err) =>
        console.error('[Redis] Erro de conexão:', err));

        await client.connect();
        redisService.client = client
        

    }

    static async get(chave: string){
        return await
    redisService.client.get(chave);

    }

    static async set(chave:string,valor:string,ttl:number){
        await redisService.client.set(chave, valor, {EX: ttl})

    }
    
    static async del(chave:string){
        await redisService.client.del(chave)
    }
    
}