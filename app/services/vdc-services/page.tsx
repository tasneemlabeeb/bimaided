"use client";

import { Box, CheckCircle2, ArrowRight, Layers, Users, Calendar, Package, Ruler, ClipboardCheck, Settings, Target, Zap, Shield, TrendingUp } from "lucide-react";
import Navigation from "@/components/Navigation";
import Footer from "@/components/Footer";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import Link from "next/link";
import { useEffect, useRef } from "react";

export default function VDCServices() {
  const servicesRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    const observer = new IntersectionObserver(
      (entries) => {
        entries.forEach((entry) => {
          if (entry.isIntersecting) {
            entry.target.classList.add('animate-slide-in-up');
          }
        });
      },
      { threshold: 0.1 }
    );

    const serviceCards = servicesRef.current?.querySelectorAll('.service-card');
    serviceCards?.forEach((card) => observer.observe(card));

    return () => observer.disconnect();
  }, []);

  const services = [
    {
      icon: Box,
      title: "Virtual Design Coordination",
      description: "Comprehensive coordination of all building systems in a virtual environment before construction begins, reducing conflicts and ensuring seamless integration.",
      strengths: [
        "Advanced 3D coordination workflows",
        "Multi-discipline clash detection and resolution",
        "Real-time collaboration platforms",
        "Detailed coordination documentation"
      ],
      coreOffering: [
        "3D model coordination across all disciplines",
        "Clash detection and resolution reports",
        "Coordination meeting facilitation",
        "Issue tracking and resolution",
        "Coordination drawing production"
      ]
    },
    {
      icon: Calendar,
      title: "Construction Planning & Sequencing",
      description: "4D BIM construction sequencing that visualizes construction timelines, identifies scheduling conflicts, and optimizes project delivery strategies.",
      strengths: [
        "Visual project timeline development",
        "Resource allocation optimization",
        "Risk identification and mitigation",
        "Stakeholder communication enhancement"
      ],
      coreOffering: [
        "4D construction simulation models",
        "Phase planning and sequencing",
        "Critical path analysis",
        "Construction logistics planning",
        "Schedule validation and optimization"
      ]
    },
    {
      icon: Package,
      title: "Prefabrication Support",
      description: "Detailed modeling and coordination support for off-site fabrication and modular construction, improving quality and reducing on-site construction time.",
      strengths: [
        "Fabrication-ready model development",
        "Tolerance and fit analysis",
        "Assembly sequence planning",
        "Quality control integration"
      ],
      coreOffering: [
        "Shop drawing coordination",
        "Fabrication model preparation",
        "Assembly planning and sequencing",
        "Transportation and logistics coordination",
        "Installation planning support"
      ]
    },
    {
      icon: Ruler,
      title: "Site Logistics Planning",
      description: "Optimize site layout, material flow, and equipment placement using 3D visualization to maximize efficiency and safety on construction sites.",
      strengths: [
        "3D site layout modeling",
        "Construction zone planning",
        "Safety analysis and planning",
        "Material flow optimization"
      ],
      coreOffering: [
        "Site mobilization planning",
        "Crane and equipment placement studies",
        "Material storage and staging plans",
        "Access and circulation routing",
        "Temporary facilities coordination"
      ]
    },
    {
      icon: ClipboardCheck,
      title: "Quality Control & QA",
      description: "Implement digital quality management processes using BIM to track, verify, and document construction quality throughout the project lifecycle.",
      strengths: [
        "Digital quality inspection workflows",
        "Model-based quality verification",
        "Real-time issue documentation",
        "Compliance tracking and reporting"
      ],
      coreOffering: [
        "Quality inspection planning",
        "Digital inspection checklists",
        "As-built verification processes",
        "Non-conformance tracking",
        "Quality documentation and reporting"
      ]
    }
  ];

  const benefits = [
    {
      icon: Target,
      title: "Improved Coordination",
      description: "Identify and resolve conflicts in the virtual environment before construction, reducing costly on-site changes.",
    },
    {
      icon: Users,
      title: "Enhanced Collaboration",
      description: "Facilitate seamless communication between all project stakeholders with visual, data-rich models.",
    },
    {
      icon: Zap,
      title: "Accelerated Delivery",
      description: "Optimize construction sequencing and prefabrication to reduce overall project duration.",
    },
    {
      icon: Shield,
      title: "Risk Mitigation",
      description: "Proactively identify and address potential issues through simulation and analysis.",
    },
    {
      icon: TrendingUp,
      title: "Cost Efficiency",
      description: "Minimize waste and rework through precise planning and coordination.",
    },
  ];

  return (
    <div className="min-h-screen bg-background">
      <Navigation />
      
      {/* Hero Section */}
      <section className="relative pt-32 pb-20 overflow-hidden">
        <div className="absolute inset-0">
          <img 
            src="/images/bim-services/VDC.jpeg" 
            alt="VDC Services Background"
            className="w-full h-full object-cover"
          />
          <div className="absolute inset-0 bg-gradient-to-br from-sky-900/85 via-sky-700/75 to-blue-800/80" />
        </div>
        
        <div className="container mx-auto px-4 relative">
          <div className="max-w-5xl mx-auto text-center">
            <Badge className="mb-6 px-4 py-2 text-sm" variant="secondary">
              Virtual Design & Construction
            </Badge>
            
            <h1 className="text-5xl md:text-6xl lg:text-7xl font-bold mb-6 text-white">
              VDC Services
            </h1>
            
            <p className="text-xl md:text-2xl text-white/90 mb-8 max-w-3xl mx-auto leading-relaxed">
              Transform your construction process with Virtual Design and Construction. Our VDC services integrate people, processes, and technology to optimize project outcomes from planning through handover.
            </p>
            
            {/* Quick Stats */}
            <div className="grid grid-cols-2 md:grid-cols-4 gap-6 max-w-4xl mx-auto">
              {[
                { value: "40%", label: "Faster Delivery" },
                { value: "99%", label: "Clash-Free Models" },
                { value: "30%", label: "Cost Reduction" },
                { value: "100%", label: "Digital Integration" },
              ].map((stat, index) => (
                <div key={index} className="p-4 rounded-xl bg-white/10 backdrop-blur-md border border-white/20">
                  <div className="text-3xl font-bold text-white mb-1">{stat.value}</div>
                  <div className="text-sm text-white/80">{stat.label}</div>
                </div>
              ))}
            </div>
          </div>
        </div>
      </section>

      {/* Services Grid */}
      <section className="py-20 bg-secondary/30">
        <div className="container mx-auto px-4">
          <div className="max-w-6xl mx-auto">
            <div className="text-center mb-16">
              <h2 className="text-4xl font-bold mb-4">Comprehensive VDC Solutions</h2>
              <p className="text-xl text-muted-foreground max-w-3xl mx-auto">
                End-to-end virtual design and construction services for optimized project delivery
              </p>
            </div>

            <div className="space-y-8" ref={servicesRef}>
              {services.map((service, index) => (
                <Card 
                  key={index} 
                  className="service-card border-border hover:shadow-xl transition-all duration-500 group overflow-hidden opacity-0 translate-y-10"
                  style={{ transitionDelay: `${index * 100}ms` }}
                >
                  <CardHeader className="pb-4 px-10 py-10">
                    <div className="flex items-center gap-3 mb-4">
                      <div className="w-12 h-12 rounded-lg bg-primary/10 flex items-center justify-center">
                        <service.icon className="text-primary" size={24} />
                      </div>
                      <CardTitle className="text-2xl">{service.title}</CardTitle>
                    </div>
                    
                    <CardDescription className="text-base leading-relaxed mb-8">
                      {service.description}
                    </CardDescription>
                    
                    <div className="grid grid-cols-1 lg:grid-cols-2 gap-10">
                      {/* Strengths */}
                      <div className="space-y-4 p-8 rounded-lg bg-secondary/30">
                        <h4 className="font-semibold text-base text-primary uppercase tracking-wide flex items-center gap-2 mb-5">
                          <Target className="w-5 h-5" />
                          Key Strengths
                        </h4>
                        <ul className="space-y-4">
                          {service.strengths.map((strength, idx) => (
                            <li key={idx} className="flex items-start gap-3 text-sm text-muted-foreground leading-relaxed">
                              <CheckCircle2 className="w-5 h-5 text-primary mt-0.5 flex-shrink-0" />
                              <span>{strength}</span>
                            </li>
                          ))}
                        </ul>
                      </div>

                      {/* Core Offering */}
                      <div className="space-y-4 p-8 bg-primary/5 rounded-lg border-l-4 border-primary">
                        <h4 className="font-semibold text-base text-primary uppercase tracking-wide flex items-center gap-2 mb-5">
                          <Layers className="w-5 h-5" />
                          Core Offering
                        </h4>
                        <ul className="space-y-4">
                          {service.coreOffering.map((offering, idx) => (
                            <li key={idx} className="flex items-start gap-3 text-sm leading-relaxed">
                              <ArrowRight className="w-5 h-5 text-primary mt-0.5 flex-shrink-0" />
                              <span className="font-medium">{offering}</span>
                            </li>
                          ))}
                        </ul>
                      </div>
                    </div>
                  </CardHeader>
                </Card>
              ))}
            </div>
          </div>
        </div>
      </section>

      {/* Benefits Section */}
      <section className="py-20">
        <div className="container mx-auto px-4">
          <div className="max-w-6xl mx-auto">
            <div className="text-center mb-16">
              <h2 className="text-4xl font-bold mb-4">Why Choose Our VDC Services</h2>
              <p className="text-xl text-muted-foreground max-w-3xl mx-auto">
                Experience measurable improvements in project outcomes through digital construction innovation
              </p>
            </div>

            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
              {benefits.map((benefit, index) => (
                <Card key={index} className="border-border hover:shadow-lg transition-all group">
                  <CardHeader>
                    <div className="w-12 h-12 rounded-lg bg-primary/10 flex items-center justify-center mb-4 group-hover:bg-primary/20 transition-colors">
                      <benefit.icon className="text-primary" size={24} />
                    </div>
                    <CardTitle className="text-lg mb-2">{benefit.title}</CardTitle>
                    <CardDescription className="leading-relaxed">
                      {benefit.description}
                    </CardDescription>
                  </CardHeader>
                </Card>
              ))}
            </div>
          </div>
        </div>
      </section>

      {/* CTA Section */}
      <section className="py-20 bg-secondary/30">
        <div className="container mx-auto px-4">
          <Card className="bg-gradient-to-br from-primary via-primary to-primary/90 border-0 text-white max-w-4xl mx-auto overflow-hidden relative">
            <div className="absolute inset-0 bg-grid-pattern opacity-10" />
            <CardHeader className="text-center py-16 relative">
              <CardTitle className="text-4xl md:text-5xl mb-6 text-white">
                Ready to Optimize Your Construction Process?
              </CardTitle>
              <CardDescription className="text-xl text-white/90 mb-8 max-w-2xl mx-auto">
                Connect with our VDC specialists to discover how virtual design and construction can transform your project delivery
              </CardDescription>
              <div className="flex flex-col sm:flex-row gap-4 justify-center">
                <Button size="lg" variant="secondary" className="text-lg px-8">
                  Get Started Today
                </Button>
                <Link href="/services">
                  <Button size="lg" variant="outline" className="text-lg px-8 border-white/30 text-white bg-transparent hover:bg-white hover:text-sky-600 font-semibold backdrop-blur-sm transition-all rounded-full shadow-lg">
                    View All Services
                  </Button>
                </Link>
              </div>
            </CardHeader>
          </Card>
        </div>
      </section>

      <Footer />
    </div>
  );
}
