const express = require('express');
const cors = require('cors');
const multer = require('multer');
const { google } = require('googleapis');
require('dotenv').config({ path: '../.env' });

const app = express();
const PORT = process.env.PORT || 3001;

// Middleware
app.use(cors());
app.use(express.json({ limit: '10mb' }));

// Google Drive Configuration
const GOOGLE_DRIVE_CREDENTIALS = {
  type: "service_account",
  project_id: process.env.VITE_GOOGLE_PROJECT_ID,
  private_key_id: process.env.VITE_GOOGLE_PRIVATE_KEY_ID,
  private_key: process.env.VITE_GOOGLE_PRIVATE_KEY?.replace(/\\n/g, '\n'),
  client_email: process.env.VITE_GOOGLE_CLIENT_EMAIL,
  client_id: process.env.VITE_GOOGLE_CLIENT_ID,
  auth_uri: "https://accounts.google.com/o/oauth2/auth",
  token_uri: "https://oauth2.googleapis.com/token",
  auth_provider_x509_cert_url: "https://www.googleapis.com/oauth2/v1/certs",
  client_x509_cert_url: process.env.VITE_GOOGLE_CERT_URL,
};

const FOLDER_ID = process.env.VITE_GOOGLE_DRIVE_FOLDER_ID;

// Initialize Google Drive
const initializeDrive = () => {
  const auth = new google.auth.GoogleAuth({
    credentials: GOOGLE_DRIVE_CREDENTIALS,
    scopes: ['https://www.googleapis.com/auth/drive.file'],
  });
  return google.drive({ version: 'v3', auth });
};

// We'll upload directly to the main folder since service accounts can't create folders
// Instead, we'll prefix the filename with employee name
const getEmployeeFileName = (employeeName, leaveRequestId, fileName) => {
  return `${employeeName}_${leaveRequestId}_${fileName}`;
};

// Health check endpoint
app.get('/api/health', (req, res) => {
  res.json({ status: 'OK', message: 'BIMaided API Server is running' });
});

// Upload file to Google Drive
app.post('/api/upload-to-drive', async (req, res) => {
  try {
    const { fileName, fileData, mimeType, employeeName, leaveRequestId } = req.body;

    console.log('Upload request received:', { 
      fileName, 
      mimeType, 
      employeeName, 
      leaveRequestId,
      fileDataLength: fileData?.length 
    });

    if (!fileName || !fileData || !mimeType || !employeeName || !leaveRequestId) {
      return res.status(400).json({ error: 'Missing required fields' });
    }

    // Initialize Drive
    const drive = initializeDrive();

    // Convert base64 to buffer
    const buffer = Buffer.from(fileData, 'base64');
    console.log('Buffer created, size:', buffer.length, 'bytes');

    // Create a readable stream from buffer
    const { Readable } = require('stream');
    const stream = Readable.from(buffer);

    // Prepare file metadata - upload directly to main folder with employee name prefix
    const fullFileName = getEmployeeFileName(employeeName, leaveRequestId, fileName);
    const fileMetadata = {
      name: fullFileName,
      parents: [FOLDER_ID],
      mimeType: mimeType,
    };

    console.log('Uploading file with metadata:', fileMetadata);

    // Upload file
    const response = await drive.files.create({
      requestBody: fileMetadata,
      media: {
        mimeType: mimeType,
        body: stream,
      },
      fields: 'id, name, webViewLink, webContentLink, size',
    });

    console.log('File uploaded successfully:', response.data);

    // Make file accessible
    await drive.permissions.create({
      fileId: response.data.id,
      requestBody: {
        role: 'reader',
        type: 'anyone',
      },
    });

    console.log('Permissions set successfully');

    res.json({
      success: true,
      fileId: response.data.id,
      fileName: response.data.name,
      fileSize: response.data.size,
      webViewLink: response.data.webViewLink,
      webContentLink: response.data.webContentLink,
    });
  } catch (error) {
    console.error('Upload error details:', error);
    res.status(500).json({ 
      error: 'Failed to upload file',
      message: error.message,
      details: error.stack 
    });
  }
});

// Delete file from Google Drive
app.delete('/api/delete-from-drive/:fileId', async (req, res) => {
  try {
    const { fileId } = req.params;
    
    const drive = initializeDrive();
    await drive.files.delete({ fileId });

    res.json({ success: true, message: 'File deleted successfully' });
  } catch (error) {
    console.error('Delete error:', error);
    res.status(500).json({ 
      error: 'Failed to delete file',
      message: error.message 
    });
  }
});

// Start server
app.listen(PORT, () => {
  console.log(`🚀 BIMaided API Server running on port ${PORT}`);
  console.log(`📁 Google Drive Folder ID: ${FOLDER_ID}`);
});
