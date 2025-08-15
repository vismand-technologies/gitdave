import { contextBridge } from 'electron';

contextBridge.exposeInMainWorld('api', {
  // reserved for future IPC-safe APIs
});

export {};
