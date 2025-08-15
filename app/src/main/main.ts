import { app, BrowserWindow } from 'electron';
import * as path from 'path';

// Disable GPU acceleration to avoid initialization errors in some environments
app.disableHardwareAcceleration();

const createWindow = async () => {
  const win = new BrowserWindow({
    width: 1100,
    height: 720,
    minWidth: 900,
    minHeight: 600,
    webPreferences: {
      preload: path.join(__dirname, 'preload.js'),
      contextIsolation: true,
      nodeIntegration: false,
      sandbox: true,
    },
    show: false,
    autoHideMenuBar: true,
  });

  // Ensure window is visible and frontmost
  win.setBounds({ x: 100, y: 100, width: 1100, height: 720 });
  win.center();
  win.once('ready-to-show', () => {
    // Temporarily force on top to ensure it surfaces above other windows, then revert
    win.setAlwaysOnTop(true, 'screen-saver');
    win.show();
    win.focus();
    win.maximize();
    setTimeout(() => {
      win.setAlwaysOnTop(false);
    }, 500);
  });
  await win.loadFile(path.join(__dirname, 'index.html'));
};

app.whenReady().then(() => {
  createWindow();

  app.on('activate', function () {
    if (BrowserWindow.getAllWindows().length === 0) createWindow();
  });
});

app.on('window-all-closed', function () {
  if (process.platform !== 'darwin') app.quit();
});
