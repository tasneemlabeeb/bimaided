-- Create contact_inquiries table
CREATE TABLE IF NOT EXISTS contact_inquiries (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  email VARCHAR(255) NOT NULL,
  phone VARCHAR(50) NOT NULL,
  subject VARCHAR(500) NOT NULL,
  message TEXT NOT NULL,
  status VARCHAR(50) DEFAULT 'new' CHECK (status IN ('new', 'in-progress', 'resolved', 'closed')),
  admin_notes TEXT,
  assigned_to UUID,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Add RLS policies for contact_inquiries
ALTER TABLE contact_inquiries ENABLE ROW LEVEL SECURITY;

-- Allow anyone to insert contact inquiries (public form submission)
-- Note: Must specify both anon and authenticated for Supabase
CREATE POLICY "Anyone can submit contact inquiries"
ON contact_inquiries
FOR INSERT
TO anon, authenticated
WITH CHECK (true);

-- Only admins can view all contact inquiries
CREATE POLICY "Admin can view all contact inquiries"
ON contact_inquiries
FOR SELECT
TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM user_roles
    WHERE user_roles.user_id = auth.uid()
    AND user_roles.role = 'admin'
  )
);

-- Only admins can update contact inquiries
CREATE POLICY "Admin can update contact inquiries"
ON contact_inquiries
FOR UPDATE
TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM user_roles
    WHERE user_roles.user_id = auth.uid()
    AND user_roles.role = 'admin'
  )
)
WITH CHECK (
  EXISTS (
    SELECT 1 FROM user_roles
    WHERE user_roles.user_id = auth.uid()
    AND user_roles.role = 'admin'
  )
);

-- Only admins can delete contact inquiries
CREATE POLICY "Admin can delete contact inquiries"
ON contact_inquiries
FOR DELETE
TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM user_roles
    WHERE user_roles.user_id = auth.uid()
    AND user_roles.role = 'admin'
  )
);

-- Create indexes for faster lookups
CREATE INDEX IF NOT EXISTS idx_contact_inquiries_status ON contact_inquiries(status);
CREATE INDEX IF NOT EXISTS idx_contact_inquiries_created_at ON contact_inquiries(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_contact_inquiries_email ON contact_inquiries(email);

-- Add comment for documentation
COMMENT ON TABLE contact_inquiries IS 'Stores contact form submissions from the website';
COMMENT ON COLUMN contact_inquiries.status IS 'Current status of the inquiry: new, in-progress, resolved, or closed';
COMMENT ON COLUMN contact_inquiries.admin_notes IS 'Internal notes added by admin staff';
COMMENT ON COLUMN contact_inquiries.assigned_to IS 'Employee assigned to handle this inquiry';
