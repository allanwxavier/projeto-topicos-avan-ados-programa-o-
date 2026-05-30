import { Request, Response } from 'express';
import packageJson from '../../package.json';

export const versionController = {
  getVersion: (_req: Request, res: Response) => {
    try {
      res.json({
        version: packageJson.version,
        environment: process.env.ENVIRONMENT || process.env.NODE_ENV || 'development',
        buildDate: new Date().toISOString()
      });
    } catch (error: any) {
      res.status(500).json({
        status: 'error',
        message: 'Erro ao obter informações de versão',
        error: error.message
      });
    }
  }
};
