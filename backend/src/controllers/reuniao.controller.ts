import { Request, Response } from "express";
import { ReuniaoService } from "../services/reuniao.service";

const reuniaoService = new ReuniaoService();

export class ReuniaoController{
    async listar(req: Request, res: Response){
        try{
            const reunioes = await reuniaoService.listarTodas();
            res.json({status: 'ok', data: reunioes});
        } catch(error) {
            res.status(500).json({ status: 'error', message: 'Erro ao listar reuniões'});
        }
    }
    async criar(req: Request, res: Response) {
        try{
            const reuniao = await reuniaoService.criar(req.body);
            res.json({ status: 'ok', data: reuniao});
        } catch (error){
            res.status(500).json({ status: 'error', message: 'Erro ao criar reuniao'})
        }
    }
    async adicionarParticipante(req: Request, res: Response) {
    try {
      const { idReuniao, idParticipante } = req.body;
      await reuniaoService.adcionarParticipante(idReuniao, idParticipante);
      res.json({ status: 'ok', message: 'Participante adicionado' });
    } catch (error) {
      res.status(500).json({ status: 'error', message: 'Erro ao adicionar participante' });
    }
  }
   async listarParticipantes(req: Request, res: Response) {
    try {
      const { idReuniao } = req.body;
      const participantes = await reuniaoService.listarParticipantes(idReuniao);
      res.json({ status: 'ok', data: participantes });
    } catch (error) {
      res.status(500).json({ status: 'error', message: 'Erro ao listar participantes' });
    }
  }
}