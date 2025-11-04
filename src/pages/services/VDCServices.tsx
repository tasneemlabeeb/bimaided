import { Box, CheckCircle2, ArrowRight } from "lucide-react";
import Navigation from "@/components/Navigation";
import Footer from "@/components/Footer";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Link } from "react-router-dom";

const VDCServices = () => {
  const features = [
    "Virtual Design Coordination",
    "Construction Planning",
    "Site Logistics Planning",
    "Prefabrication Support",
    "Quality Control & QA",
    "Construction Simulation",
    "Trade Coordination",
    "Installation Planning",
  ];

  const benefits = [
    "Reduced construction time",
    "Minimized on-site conflicts",
    "Enhanced coordination",
    "Improved construction quality",
    "Optimized resource allocation",
  ];

  return (
    <div className="min-h-screen">
      <Navigation />
      
      {/* Hero Section */}
      <section className="pt-32 pb-16 bg-gradient-to-b from-primary/5 to-background">
        <div className="container mx-auto px-4">
          <div className="max-w-4xl mx-auto">
            <div className="flex items-center gap-3 mb-6">
              <div className="w-16 h-16 rounded-xl bg-primary/10 flex items-center justify-center">
                <Box className="text-primary" size={32} />
              </div>
              <h1 className="text-5xl font-bold">VDC Services</h1>
            </div>
            <p className="text-xl text-muted-foreground mb-8">
              Virtual Design & Construction coordination for seamless project delivery and execution.
            </p>
            <div className="flex gap-4">
              <Button size="lg">Get Started</Button>
              <Link to="/services">
                <Button size="lg" variant="outline">View All Services</Button>
              </Link>
            </div>
          </div>
        </div>
      </section>

      {/* Overview Section */}
      <section className="py-16">
        <div className="container mx-auto px-4">
          <div className="max-w-4xl mx-auto">
            <h2 className="text-3xl font-bold mb-6">Overview</h2>
            <div className="prose prose-lg max-w-none">
              <p className="text-muted-foreground leading-relaxed">
                Our VDC services bridge the gap between design and construction through virtual coordination 
                and planning. We help construction teams visualize, plan, and execute complex projects with 
                precision, reducing conflicts and improving efficiency on site.
              </p>
              <p className="text-muted-foreground leading-relaxed mt-4">
                [Add your detailed description here]
              </p>
            </div>
          </div>
        </div>
      </section>

      {/* Features Grid */}
      <section className="py-16 bg-secondary">
        <div className="container mx-auto px-4">
          <div className="max-w-4xl mx-auto">
            <h2 className="text-3xl font-bold mb-8">What We Offer</h2>
            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
              {features.map((feature, index) => (
                <Card key={index} className="border-border">
                  <CardHeader className="flex flex-row items-center gap-3 pb-3">
                    <CheckCircle2 className="text-primary flex-shrink-0" size={24} />
                    <CardTitle className="text-lg">{feature}</CardTitle>
                  </CardHeader>
                </Card>
              ))}
            </div>
          </div>
        </div>
      </section>

      {/* Benefits Section */}
      <section className="py-16">
        <div className="container mx-auto px-4">
          <div className="max-w-4xl mx-auto">
            <h2 className="text-3xl font-bold mb-8">Key Benefits</h2>
            <div className="space-y-4">
              {benefits.map((benefit, index) => (
                <div key={index} className="flex items-start gap-4 p-4 rounded-lg hover:bg-secondary transition-colors">
                  <ArrowRight className="text-primary flex-shrink-0 mt-1" size={20} />
                  <div>
                    <h3 className="font-semibold text-lg mb-1">{benefit}</h3>
                    <p className="text-muted-foreground">[Add benefit description here]</p>
                  </div>
                </div>
              ))}
            </div>
          </div>
        </div>
      </section>

      {/* CTA Section */}
      <section className="py-16 bg-secondary">
        <div className="container mx-auto px-4">
          <Card className="bg-gradient-to-r from-primary to-primary/90 border-0 text-white max-w-4xl mx-auto">
            <CardHeader className="text-center py-12">
              <CardTitle className="text-3xl mb-4 text-white">Ready to Get Started?</CardTitle>
              <CardDescription className="text-lg text-white/90 mb-6">
                Let's discuss how our VDC services can streamline your construction process
              </CardDescription>
              <Button size="lg" variant="secondary">
                Contact Us Today
              </Button>
            </CardHeader>
          </Card>
        </div>
      </section>

      <Footer />
    </div>
  );
};

export default VDCServices;
