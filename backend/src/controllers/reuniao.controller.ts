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
        const { assunto, local, data, horaInicio, horaFim } = req.body;

        if (!assunto || !local || !data || !horaInicio || !horaFim) {
          return res.status(400).json({
            status: 'error',
            message: 'Campos obrigatórios ausentes: assunto, local, data, horaInicio e horaFim são necessários.'
          });
        }

        try{
            const reuniao = await reuniaoService.criar(req.body); 
            res.status(201).json({ status: 'ok', data: reuniao});
        } catch (error){
            res.status(500).json({ status: 'error', message: 'Erro ao criar reuniao'})
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
       res.json({ status: 'ok', message: 'Participante adicionado' });
     } catch (error) {
       res.status(500).json({ status: 'error', message: 'Erro ao adicionar participante' });
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