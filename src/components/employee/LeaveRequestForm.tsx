import { useState } from "react";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Textarea } from "@/components/ui/textarea";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { supabase } from "@/integrations/supabase/client";
import { useToast } from "@/hooks/use-toast";

interface LeaveRequestFormProps {
  employeeId: string;
  onSuccess: () => void;
}

const LeaveRequestForm = ({ employeeId, onSuccess }: LeaveRequestFormProps) => {
  const [loading, setLoading] = useState(false);
  const { toast } = useToast();

  const [formData, setFormData] = useState({
    date: "",
    leaveType: "",
    reason: "",
  });

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);

    try {
      const { error } = await supabase.from("attendance").insert({
        employee_id: employeeId,
        date: formData.date,
        status: "Leave" as any,
        leave_type: formData.leaveType as any,
        leave_reason: formData.reason,
        leave_approved: false,
      } as any);

      if (error) throw error;

      toast({
        title: "Leave request submitted",
        description: "Your leave request has been submitted for approval.",
      });

      setFormData({
        date: "",
        leaveType: "",
        reason: "",
      });

      onSuccess();
    } catch (error: any) {
      toast({
        title: "Error submitting leave request",
        description: error.message,
        variant: "destructive",
      });
    } finally {
      setLoading(false);
    }
  };

  return (
    <form onSubmit={handleSubmit} className="space-y-4">
      <div className="space-y-2">
        <Label htmlFor="date">Leave Date*</Label>
        <Input
          id="date"
          type="date"
          value={formData.date}
          onChange={(e) => setFormData({ ...formData, date: e.target.value })}
          required
          min={new Date().toISOString().split("T")[0]}
        />
      </div>

      <div className="space-y-2">
        <Label htmlFor="leaveType">Leave Type*</Label>
        <Select
          value={formData.leaveType}
          onValueChange={(value) => setFormData({ ...formData, leaveType: value })}
          required
        >
          <SelectTrigger>
            <SelectValue placeholder="Select leave type" />
          </SelectTrigger>
          <SelectContent>
            <SelectItem value="Sick Leave">Sick Leave</SelectItem>
            <SelectItem value="Casual Leave">Casual Leave</SelectItem>
            <SelectItem value="Hourly Leave">Hourly Leave</SelectItem>
            <SelectItem value="Half Day Leave">Half Day Leave</SelectItem>
            <SelectItem value="Full Day Leave">Full Day Leave</SelectItem>
            <SelectItem value="Earned Leave">Earned Leave</SelectItem>
            <SelectItem value="Paid Leave">Paid Leave</SelectItem>
            <SelectItem value="Unpaid Leave">Unpaid Leave</SelectItem>
            <SelectItem value="Maternity Leave">Maternity Leave</SelectItem>
            <SelectItem value="Other Leave">Other Leave</SelectItem>
          </SelectContent>
        </Select>
      </div>

      <div className="space-y-2">
        <Label htmlFor="reason">Reason</Label>
        <Textarea
          id="reason"
          value={formData.reason}
          onChange={(e) => setFormData({ ...formData, reason: e.target.value })}
          placeholder="Please provide a reason for your leave..."
          rows={4}
        />
      </div>

      <Button type="submit" disabled={loading} className="w-full">
        {loading ? "Submitting..." : "Submit Leave Request"}
      </Button>
    </form>
  );
};

export default LeaveRequestForm;
