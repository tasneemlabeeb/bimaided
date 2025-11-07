-- =====================================================
-- Add Job Applications Table
-- =====================================================
-- Table to store job applications from career postings

CREATE TABLE IF NOT EXISTS job_applications (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  career_posting_id UUID REFERENCES career_postings(id) ON DELETE CASCADE,
  full_name VARCHAR(255) NOT NULL,
  email VARCHAR(255) NOT NULL,
  phone VARCHAR(50),
  cover_letter TEXT,
  resume_url TEXT,
  linkedin_url VARCHAR(500),
  portfolio_url VARCHAR(500),
  years_of_experience INTEGER,
  current_company VARCHAR(255),
  current_position VARCHAR(255),
  expected_salary VARCHAR(100),
  available_from DATE,
  status VARCHAR(50) DEFAULT 'pending',
  notes TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create indexes
CREATE INDEX idx_job_applications_career_posting ON job_applications(career_posting_id);
CREATE INDEX idx_job_applications_email ON job_applications(email);
CREATE INDEX idx_job_applications_status ON job_applications(status);
CREATE INDEX idx_job_applications_created_at ON job_applications(created_at DESC);

-- Create trigger for updated_at
CREATE TRIGGER update_job_applications_updated_at 
  BEFORE UPDATE ON job_applications
  FOR EACH ROW 
  EXECUTE FUNCTION update_updated_at_column();

-- Enable RLS
ALTER TABLE job_applications ENABLE ROW LEVEL SECURITY;

-- RLS Policies
CREATE POLICY "Anyone can submit job applications"
  ON job_applications FOR INSERT
  TO anon, authenticated
  WITH CHECK (true);

CREATE POLICY "Admin can view all job applications"
  ON job_applications FOR SELECT
  TO authenticated
  USING (has_role('admin', auth.uid()));

CREATE POLICY "Admin can manage all job applications"
  ON job_applications FOR ALL
  TO authenticated
  USING (has_role('admin', auth.uid()));

COMMENT ON TABLE job_applications IS 'Job applications submitted through career postings';
COMMENT ON COLUMN job_applications.status IS 'Application status: pending, reviewing, shortlisted, rejected, hired';
