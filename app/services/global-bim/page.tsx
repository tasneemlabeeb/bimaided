"use client";

import { Globe, CheckCircle2, ArrowRight, Layers, BookOpen, Users, Award, FileCheck, Briefcase, Target, Zap, Shield, TrendingUp } from "lucide-react";
import Navigation from "@/components/Navigation";
import Footer from "@/components/Footer";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import Link from "next/link";
import { useEffect, useRef } from "react";

export default function GlobalBIMServices() {
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
      icon: FileCheck,
      title: "BIM Standards Compliance",
      description: "Ensure your BIM projects meet international and regional standards including ISO 19650, AIA, BS, and local building codes for seamless global collaboration.",
      strengths: [
        "Expertise in ISO 19650 series implementation",
        "Multi-regional compliance knowledge",
        "Standardized naming conventions and protocols",
        "Quality assurance and validation processes"
      ],
      coreOffering: [
        "Standards gap analysis and assessment",
        "BIM execution plan development",
        "Template and library standardization",
        "Compliance documentation and reporting",
        "Standards training and support"
      ]
    },
    {
      icon: Briefcase,
      title: "BIM Implementation",
      description: "Strategic BIM adoption and implementation services to help organizations transition from traditional workflows to integrated BIM processes.",
      strengths: [
        "Customized implementation roadmaps",
        "Technology stack evaluation and selection",
        "Change management strategies",
        "Phased rollout planning"
      ],
      coreOffering: [
        "BIM maturity assessment",
        "Implementation strategy development",
        "Pilot project execution",
        "Process integration and optimization",
        "Success measurement and reporting"
      ]
    },
    {
      icon: BookOpen,
      title: "BIM Training & Workshops",
      description: "Comprehensive training programs for teams at all skill levels, from BIM fundamentals to advanced coordination and management techniques.",
      strengths: [
        "Certified trainers with industry experience",
        "Hands-on, project-based learning",
        "Customizable curriculum",
        "Ongoing support and mentorship"
      ],
      coreOffering: [
        "Software-specific training (Revit, Navisworks, etc.)",
        "BIM coordination and clash detection workshops",
        "BIM management and leadership courses",
        "Custom training for project requirements",
        "Certification preparation programs"
      ]
    },
    {
      icon: Users,
      title: "BIM Consulting",
      description: "Expert advisory services to optimize your BIM workflows, solve complex technical challenges, and maximize return on BIM investment.",
      strengths: [
        "Strategic BIM planning expertise",
        "Technology and workflow optimization",
        "Industry best practices integration",
        "Long-term partnership approach"
      ],
      coreOffering: [
        "BIM strategy development",
        "Workflow optimization consulting",
        "Technology evaluation and recommendations",
        "Process audit and improvement",
        "Ongoing advisory support"
      ]
    },
    {
      icon: Globe,
      title: "International Project Support",
      description: "Specialized support for projects spanning multiple countries and regions, ensuring coordination across different standards, time zones, and languages.",
      strengths: [
        "Multi-regional project experience",
        "Cross-cultural collaboration expertise",
        "24/7 global support capabilities",
        "Multilingual team members"
      ],
      coreOffering: [
        "Global project coordination",
        "Multi-standard compliance management",
        "International team collaboration facilitation",
        "Regional requirements integration",
        "Localization and translation support"
      ]
    }
  ];

  const standards = [
    { name: "ISO 19650", region: "International" },
    { name: "AIA G202/G203", region: "USA" },
    { name: "PAS 1192", region: "UK" },
    { name: "BS 1192", region: "UK" },
    { name: "NBIMS", region: "USA" },
    { name: "Singapore BIM Guide", region: "Singapore" },
    { name: "BIM Protocol", region: "Australia" },
    { name: "NBS BIM Toolkit", region: "UK" },
  ];

  const benefits = [
    {
      icon: Target,
      title: "Global Expertise",
      description: "Leverage our experience across international markets and diverse project types.",
    },
    {
      icon: Shield,
      title: "Standards Compliance",
      description: "Ensure projects meet all applicable international and regional BIM standards.",
    },
    {
      icon: Users,
      title: "Knowledge Transfer",
      description: "Build internal capabilities through comprehensive training and mentorship.",
    },
    {
      icon: Zap,
      title: "Accelerated Adoption",
      description: "Fast-track your BIM implementation with proven methodologies.",
    },
    {
      icon: TrendingUp,
      title: "Continuous Improvement",
      description: "Ongoing optimization of BIM processes for maximum efficiency.",
    },
  ];

  return (
    <div className="min-h-screen bg-background">
      <Navigation />
      
      {/* Hero Section */}
      <section className="relative pt-32 pb-20 overflow-hidden">
        <div className="absolute inset-0">
          <img 
            src="/images/bim-services/Global BIM.jpeg" 
            alt="Global BIM Services Background"
            className="w-full h-full object-cover"
          />
          <div className="absolute inset-0 bg-gradient-to-br from-sky-900/85 via-sky-700/75 to-blue-800/80" />
        </div>
        
        <div className="container mx-auto px-4 relative">
          <div className="max-w-5xl mx-auto text-center">
            <Badge className="mb-6 px-4 py-2 text-sm" variant="secondary">
              International Standards & Best Practices
            </Badge>
            
            <h1 className="text-5xl md:text-6xl lg:text-7xl font-bold mb-6 text-white">
              Global BIM Services
            </h1>
            
            <p className="text-xl md:text-2xl text-white/90 mb-8 max-w-3xl mx-auto leading-relaxed">
              Navigate the global BIM landscape with confidence. Our international BIM services ensure standards compliance, facilitate knowledge transfer, and support seamless collaboration across borders.
            </p>
            
            {/* Quick Stats */}
            <div className="grid grid-cols-2 md:grid-cols-4 gap-6 max-w-4xl mx-auto">
              {[
                { value: "25+", label: "Countries Served" },
                { value: "8+", label: "Standards Supported" },
                { value: "1000+", label: "Professionals Trained" },
                { value: "15+", label: "Years Experience" },
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
              <h2 className="text-4xl font-bold mb-4">Our Global BIM Service Portfolio</h2>
              <p className="text-xl text-muted-foreground max-w-3xl mx-auto">
                Comprehensive BIM expertise tailored for international projects and organizations
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

      {/* Standards Section */}
      <section className="py-20">
        <div className="container mx-auto px-4">
          <div className="max-w-6xl mx-auto">
            <div className="text-center mb-12">
              <h2 className="text-4xl font-bold mb-4">Supported BIM Standards</h2>
              <p className="text-xl text-muted-foreground max-w-3xl mx-auto">
                Expertise in implementing and maintaining compliance with international BIM standards
              </p>
            </div>

            <div className="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-4">
              {standards.map((standard, index) => (
                <Card key={index} className="border-border hover:border-primary/50 transition-all text-center p-6">
                  <Award className="w-8 h-8 text-primary mx-auto mb-3" />
                  <p className="font-semibold text-sm mb-1">{standard.name}</p>
                  <Badge variant="outline" className="text-xs">{standard.region}</Badge>
                </Card>
              ))}
            </div>
          </div>
        </div>
      </section>

      {/* Benefits Section */}
      <section className="py-20 bg-secondary/30">
        <div className="container mx-auto px-4">
          <div className="max-w-6xl mx-auto">
            <div className="text-center mb-16">
              <h2 className="text-4xl font-bold mb-4">Why Choose Our Global BIM Services</h2>
              <p className="text-xl text-muted-foreground max-w-3xl mx-auto">
                Partner with industry experts to navigate the complexities of international BIM implementation
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
      <section className="py-20">
        <div className="container mx-auto px-4">
          <Card className="bg-gradient-to-br from-primary via-primary to-primary/90 border-0 text-white max-w-4xl mx-auto overflow-hidden relative">
            <div className="absolute inset-0 bg-grid-pattern opacity-10" />
            <CardHeader className="text-center py-16 relative">
              <CardTitle className="text-4xl md:text-5xl mb-6 text-white">
                Ready to Go Global with BIM?
              </CardTitle>
              <CardDescription className="text-xl text-white/90 mb-8 max-w-2xl mx-auto">
                Connect with our international BIM experts to ensure your projects meet global standards and best practices
              </CardDescription>
              <div className="flex flex-col sm:flex-row gap-4 justify-center">
                <Button size="lg" variant="secondary" className="text-lg px-8">
                  Schedule Consultation
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
