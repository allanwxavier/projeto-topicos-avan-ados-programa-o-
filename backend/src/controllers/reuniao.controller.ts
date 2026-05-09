import { Request, Response } from "express";
import { ReuniaoService } from "../services/reuniao.service";
import { RabbitMQService } from '../services/rabbitmq.service';
import crypto from "crypto"; // Adicionado: Gera um ID único para o evento (Idempotência)

const reuniaoService = new ReuniaoService();

export class ReuniaoController {


    async listar(req: Request, res: Response){
        try{
            const reunioes = await reuniaoService.listarTodas();
            res.json({status: 'ok', data: reunioes});
        } catch(error) {
            res.status(500).json({ status: 'error', message: 'Erro ao listar reuniões'});
        }
    }

    async criar(req: Request, res: Response) {
        const { assunto, local, data, horaInicio, horaFim } = req.body;

        if (!assunto || !local || !data || !horaInicio || !horaFim) {
            return res.status(400).json({
                status: 'error',
                message: 'Campos obrigatórios ausentes.'
            });
        }

        try {
            // PASSO 1: Gravar no Write Database (Node)
            const reuniao = await reuniaoService.criar(req.body);

            // PASSO 2: Montar a estrutura Padrão do Evento (Idempotência)
            const evento = {
                eventId: crypto.randomUUID(), // Dev 2 usará isso para não duplicar dados
                tipo: 'ReuniaoCriadaEvent',
                dataPublicacao: new Date().toISOString(),
                payload: {
                    id: reuniao.id,
                    titulo: reuniao.assunto,
                    descricao: reuniao.local,
                    data: reuniao.data,
                    horaInicio: reuniao.horaInicio,
                    horaFim: reuniao.horaFim
                }
            };

            
            
            await RabbitMQService.enviarParaFila('reuniao_events', JSON.stringify(evento));

            
            return res.status(201).json({ status: 'ok', data: reuniao });
        } catch (error) {
            console.error(error);
            return res.status(500).json({ status: 'error', message: 'Erro ao criar reunião' });
        }
    }

    async adicionarParticipante(req: Request, res: Response) {
        const { idReuniao, idParticipante } = req.body;

        if(!idReuniao || !idParticipante) {
            return res.status(400).json({
                status: 'error',
                message: 'idReuniao e idParticipante são obrigatórios.'
            });
        }

        try {
            
            await reuniaoService.adicionarParticipante(idReuniao, idParticipante);

            
            const evento = {
                eventId: crypto.randomUUID(),
                tipo: 'ParticipanteAdicionadoEvent',
                dataPublicacao: new Date().toISOString(),
                payload: {
                    idReuniao,
                    idParticipante
                }
            };

            await RabbitMQService.enviarParaFila('reuniao_events', JSON.stringify(evento));

            return res.json({ status: 'ok', message: 'Participante adicionado' });
        } catch (error) {
            console.error(error);
            return res.status(500).json({ status: 'error', message: 'Erro ao adicionar participante' });
        }
    }

    async listarParticipantes(req: Request, res: Response) {
        const { idReuniao } = req.body;    

        if (!idReuniao) {
            return res.status(400).json({ 
                status: 'error',
                message: 'idReuniao é obrigatório'
            });
        }

        try {
            const participantes = await reuniaoService.listarParticipantes(idReuniao);
            res.json({ status: 'ok', data: participantes });
        } catch (error) {
            res.status(500).json({ status: 'error', message: 'Erro ao listar participantes' });
        }
    }
}