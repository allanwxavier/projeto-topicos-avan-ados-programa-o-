import { Router, Request, Response } from 'express';
import { registry } from '../config/metrics';

const router = Router();

/**
 * GET /metrics
 *
 * Endpoint padrão consumido pelo Prometheus (configurado em prometheus.yml
 * pelo Dev 1). Devolve texto puro no formato Prometheus exposition format.
 *
 * Não autenticar: o scraper precisa acessar livremente DENTRO da rede
 * docker (cqrs-net). Se quiser proteger contra acesso externo, basta
 * fechar a porta no firewall ou usar um middleware que aceite apenas
 * o IP do container do Prometheus.
 */
router.get('/', async (_req: Request, res: Response) => {
  try {
    res.setHeader('Content-Type', registry.contentType);
    res.send(await registry.metrics());
  } catch (err: any) {
    res.status(500).send(`# Erro ao gerar metrics: ${err?.message}`);
  }
});

export default router;
