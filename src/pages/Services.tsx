import { Building2, Layers, Box, Globe } from "lucide-react";
import Navigation from "@/components/Navigation";
import Footer from "@/components/Footer";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";

const Services = () => {
  const services = [
    {
      icon: Building2,
      title: "BIM Modeling",
      description: "Comprehensive 3D modeling services for architectural, structural, and MEP systems.",
      features: [
        "Architectural BIM Modeling",
        "Structural BIM Modeling",
        "MEP BIM Modeling",
        "3D Visualization",
        "Scan to BIM Services",
      ],
    },
    {
      icon: Layers,
      title: "Advanced BIM Services",
      description: "Sophisticated BIM solutions for complex project requirements.",
      features: [
        "Clash Detection & Coordination",
        "4D BIM (Construction Sequencing)",
        "5D BIM (Cost Estimation)",
        "6D BIM (Facility Management)",
        "BIM Quantity Takeoff",
      ],
    },
    {
      icon: Box,
      title: "VDC Services",
      description: "Virtual Design & Construction coordination for seamless project delivery.",
      features: [
        "Virtual Design Coordination",
        "Construction Planning",
        "Site Logistics Planning",
        "Prefabrication Support",
        "Quality Control & QA",
      ],
    },
    {
      icon: Globe,
      title: "Global BIM Services",
      description: "International BIM standards compliance and consulting services.",
      features: [
        "BIM Standards Compliance",
        "BIM Implementation",
        "BIM Training & Workshops",
        "BIM Consulting",
        "International Project Support",
      ],
    },
  ];

  return (
    <div className="min-h-screen">
      <Navigation />
      
      {/* Hero Section */}
      <section className="pt-32 pb-16 bg-gradient-to-b from-secondary to-background">
        <div className="container mx-auto px-4">
          <div className="max-w-3xl mx-auto text-center">
            <h1 className="text-5xl font-bold mb-6">Our Services</h1>
            <p className="text-xl text-muted-foreground">
              Comprehensive BIM solutions designed to enhance your construction projects from concept to completion
            </p>
          </div>
        </div>
      </section>

      {/* Services Grid */}
      <section className="py-16">
        <div className="container mx-auto px-4">
          <div className="grid grid-cols-1 md:grid-cols-2 gap-8">
            {services.map((service, index) => (
              <Card key={index} className="border-border hover:shadow-xl transition-all">
                <CardHeader>
                  <div className="w-16 h-16 rounded-xl bg-primary/10 flex items-center justify-center mb-4">
                    <service.icon className="text-primary" size={32} />
                  </div>
                  <CardTitle className="text-2xl">{service.title}</CardTitle>
                  <CardDescription className="text-base">{service.description}</CardDescription>
                </CardHeader>
                <CardContent>
                  <ul className="space-y-2">
                    {service.features.map((feature, idx) => (
                      <li key={idx} className="flex items-center gap-2">
                        <div className="w-1.5 h-1.5 rounded-full bg-primary" />
                        <span className="text-sm">{feature}</span>
                      </li>
                    ))}
                  </ul>
                </CardContent>
              </Card>
            ))}
          </div>
        </div>
      </section>

      <Footer />
    </div>
  );
};

export default Services;
