# 📦 Supabase Storage Buckets Guide

## Overview

This document explains the storage bucket configuration for BIMSync Portal, including bucket structure, policies, and usage guidelines.

---

## 🗂️ Storage Buckets

### 1. **employee-photos** 
**Purpose:** Employee profile photos

| Property | Value |
|----------|-------|
| **ID** | `employee-photos` |
| **Visibility** | Private |
| **File Size Limit** | 5 MB |
| **Allowed Types** | JPEG, JPG, PNG, WebP |
| **Structure** | `/{user_id}/{filename}` |

**Access Control:**
- ✅ Employees can upload/update/delete their own photos
- ✅ All authenticated users can view all photos (team directory)
- ✅ Admins have full access

**Example Paths:**
```
employee-photos/
  ├── {user-id-1}/
  │   └── profile.jpg
  ├── {user-id-2}/
  │   └── avatar.png
```

---

### 2. **employee-documents**
**Purpose:** Employee documents (ID cards, certificates, contracts)

| Property | Value |
|----------|-------|
| **ID** | `employee-documents` |
| **Visibility** | Private |
| **File Size Limit** | 10 MB |
| **Allowed Types** | PDF, JPEG, JPG, PNG, DOC, DOCX |
| **Structure** | `/{user_id}/{document_type}/{filename}` |

**Access Control:**
- ✅ Employees can upload/view/delete their own documents
- ✅ Admins have full access
- ❌ Other employees cannot view

**Example Paths:**
```
employee-documents/
  ├── {user-id}/
  │   ├── passport/
  │   │   └── passport-copy.pdf
  │   ├── certificates/
  │   │   ├── degree.pdf
  │   │   └── certification.jpg
  │   └── contracts/
  │       └── employment-contract.pdf
```

---

### 3. **project-images**
**Purpose:** Portfolio project images for public website

| Property | Value |
|----------|-------|
| **ID** | `project-images` |
| **Visibility** | **Public** 🌐 |
| **File Size Limit** | 10 MB |
| **Allowed Types** | JPEG, JPG, PNG, WebP |
| **Structure** | `/{project_id}/{filename}` |

**Access Control:**
- ✅ **Public** - Anyone can view (no authentication required)
- ✅ Admins can upload/update/delete
- ❌ Regular employees cannot upload

**Example Paths:**
```
project-images/
  ├── {project-id-1}/
  │   ├── main-image.jpg
  │   ├── gallery-1.jpg
  │   └── gallery-2.jpg
  ├── {project-id-2}/
  │   └── featured.png
```

**Usage:** These images are displayed on the public website portfolio page.

---

### 4. **leave-attachments**
**Purpose:** Medical certificates and leave supporting documents

| Property | Value |
|----------|-------|
| **ID** | `leave-attachments` |
| **Visibility** | Private |
| **File Size Limit** | 5 MB |
| **Allowed Types** | JPEG, JPG, PNG, PDF |
| **Structure** | `/{user_id}/{leave_request_id}/{filename}` |

**Access Control:**
- ✅ Employees can upload/view their own attachments
- ✅ Supervisors can view team attachments
- ✅ Admins have full access

**Example Paths:**
```
leave-attachments/
  ├── {user-id}/
  │   ├── {leave-req-1}/
  │   │   └── medical-certificate.pdf
  │   ├── {leave-req-2}/
  │   │   └── sick-note.jpg
```

---

## 🔒 Security Policies Summary

### Row Level Security (RLS) for Storage

All storage buckets have Row Level Security policies configured:

| Bucket | Upload | View | Update | Delete |
|--------|--------|------|--------|--------|
| **employee-photos** | Self + Admin | All Auth Users | Self + Admin | Self + Admin |
| **employee-documents** | Self + Admin | Self + Admin | - | Self + Admin |
| **project-images** | Admin Only | **Public** | Admin Only | Admin Only |
| **leave-attachments** | Self + Admin | Self + Supervisor + Admin | - | Admin Only |

**Legend:**
- **Self** - The employee who owns the file
- **Admin** - Users with admin role
- **Supervisor** - Direct supervisor of the employee
- **Public** - No authentication required
- **All Auth Users** - Any logged-in user

---

## 📝 Usage Examples

### Upload Profile Photo (TypeScript)

```typescript
import { supabase } from '@/integrations/supabase/client';

async function uploadProfilePhoto(file: File, userId: string) {
  const fileExt = file.name.split('.').pop();
  const fileName = `${userId}/profile.${fileExt}`;
  
  const { data, error } = await supabase.storage
    .from('employee-photos')
    .upload(fileName, file, {
      cacheControl: '3600',
      upsert: true // Replace existing file
    });
    
  if (error) {
    console.error('Upload error:', error);
    return null;
  }
  
  // Get public URL
  const { data: urlData } = supabase.storage
    .from('employee-photos')
    .getPublicUrl(fileName);
    
  return urlData.publicUrl;
}
```

### Upload Employee Document

```typescript
async function uploadDocument(
  file: File, 
  userId: string, 
  documentType: string
) {
  const fileName = `${userId}/${documentType}/${file.name}`;
  
  const { data, error } = await supabase.storage
    .from('employee-documents')
    .upload(fileName, file);
    
  if (error) {
    console.error('Upload error:', error);
    return null;
  }
  
  return data.path;
}
```

### Upload Project Image (Admin Only)

```typescript
async function uploadProjectImage(file: File, projectId: string) {
  const fileExt = file.name.split('.').pop();
  const fileName = `${projectId}/${Date.now()}.${fileExt}`;
  
  const { data, error } = await supabase.storage
    .from('project-images')
    .upload(fileName, file);
    
  if (error) {
    console.error('Upload error:', error);
    return null;
  }
  
  // Get public URL (no auth required)
  const { data: urlData } = supabase.storage
    .from('project-images')
    .getPublicUrl(fileName);
    
  return urlData.publicUrl;
}
```

### Upload Leave Attachment

```typescript
async function uploadLeaveAttachment(
  file: File, 
  userId: string, 
  leaveRequestId: string
) {
  const fileName = `${userId}/${leaveRequestId}/${file.name}`;
  
  const { data, error } = await supabase.storage
    .from('leave-attachments')
    .upload(fileName, file);
    
  if (error) {
    console.error('Upload error:', error);
    return null;
  }
  
  return data.path;
}
```

### List Files in Bucket

```typescript
async function listEmployeeDocuments(userId: string) {
  const { data, error } = await supabase.storage
    .from('employee-documents')
    .list(userId);
    
  if (error) {
    console.error('List error:', error);
    return [];
  }
  
  return data;
}
```

### Delete File

```typescript
async function deleteFile(bucket: string, filePath: string) {
  const { error } = await supabase.storage
    .from(bucket)
    .remove([filePath]);
    
  if (error) {
    console.error('Delete error:', error);
    return false;
  }
  
  return true;
}
```

### Get Signed URL (Private Files)

```typescript
async function getSignedUrl(bucket: string, filePath: string) {
  const { data, error } = await supabase.storage
    .from(bucket)
    .createSignedUrl(filePath, 3600); // Valid for 1 hour
    
  if (error) {
    console.error('Signed URL error:', error);
    return null;
  }
  
  return data.signedUrl;
}
```

---

## 🚀 Setup Instructions

### Step 1: Run the SQL Script

Execute `07_create_storage_buckets.sql` in Supabase SQL Editor:

```bash
# Or via command line
psql -h your-host -U postgres -d postgres -f 07_create_storage_buckets.sql
```

### Step 2: Verify Buckets Created

In Supabase Dashboard:
1. Go to **Storage** (left sidebar)
2. You should see 4 buckets:
   - employee-photos
   - employee-documents
   - project-images ⭐ (public)
   - leave-attachments

### Step 3: Test Upload

Try uploading a test file through your application or using the Supabase dashboard.

---

## 📊 File Organization Best Practices

### 1. Use Consistent Naming

```
✅ Good:
- employee-photos/{user-id}/profile.jpg
- employee-documents/{user-id}/passport/passport-2024.pdf

❌ Bad:
- employee-photos/photo123.jpg
- employee-documents/doc.pdf
```

### 2. Include User/Entity IDs in Path

This makes RLS policies more effective and files easier to manage.

### 3. Use Timestamps for Versions

```
project-images/{project-id}/image-1699264800000.jpg
```

### 4. Keep File Names Clean

- Use lowercase
- Replace spaces with hyphens
- Remove special characters

---

## 🔍 Troubleshooting

### Error: "new row violates row-level security policy"

**Cause:** User doesn't have permission to upload to this path.

**Solution:** 
- Check file path structure
- Ensure user_id matches `auth.uid()`
- Verify user has correct role for admin-only buckets

### Error: "File size exceeds limit"

**Cause:** File is too large for the bucket.

**Solution:**
- Compress images before upload
- Split large documents
- Check bucket limits in the table above

### Error: "Invalid MIME type"

**Cause:** File type not allowed for this bucket.

**Solution:**
- Check allowed types in the table above
- Convert file to supported format

### Images Not Displaying

**Cause:** Incorrect URL or permissions.

**Solution:**
- For public buckets: Use `getPublicUrl()`
- For private buckets: Use `createSignedUrl()`
- Check RLS policies

---

## 🔧 Maintenance

### Delete Old Files

```typescript
// Delete files older than 90 days
async function cleanupOldFiles(bucket: string, userId: string) {
  const { data: files } = await supabase.storage
    .from(bucket)
    .list(userId);
    
  const now = Date.now();
  const ninetyDays = 90 * 24 * 60 * 60 * 1000;
  
  const oldFiles = files.filter(file => {
    const fileDate = new Date(file.created_at).getTime();
    return (now - fileDate) > ninetyDays;
  });
  
  const filePaths = oldFiles.map(f => `${userId}/${f.name}`);
  
  await supabase.storage
    .from(bucket)
    .remove(filePaths);
}
```

### Check Storage Usage

```typescript
async function getStorageUsage() {
  const buckets = [
    'employee-photos',
    'employee-documents',
    'project-images',
    'leave-attachments'
  ];
  
  for (const bucket of buckets) {
    const { data } = await supabase.storage
      .from(bucket)
      .list();
      
    const totalSize = data?.reduce((sum, file) => 
      sum + (file.metadata?.size || 0), 0
    ) || 0;
    
    console.log(`${bucket}: ${(totalSize / 1024 / 1024).toFixed(2)} MB`);
  }
}
```

---

## 📚 Additional Resources

- [Supabase Storage Documentation](https://supabase.com/docs/guides/storage)
- [Storage Security](https://supabase.com/docs/guides/storage/security/access-control)
- [Image Transformation](https://supabase.com/docs/guides/storage/serving/image-transformations)

---

**Created:** November 6, 2025  
**Version:** 1.0.0  
**Status:** ✅ Ready to Use
