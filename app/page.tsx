"use client";

import { useState, useEffect } from "react";
import Link from "next/link";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import Navigation from "@/components/Navigation";
import Footer from "@/components/Footer";
import ParallaxHero from "@/components/ParallaxHero";
import { supabase } from "@/integrations/supabase/client";
import { Building2, Layers, Box, Globe, ArrowRight, CheckCircle2 } from "lucide-react";

export default function Landing() {
  const [featuredProjects, setFeaturedProjects] = useState<any[]>([]);
  
  const services = [
    {
      icon: Building2,
      title: "BIM Modeling",
      description: "Comprehensive 3D modeling services for architectural, structural, and MEP systems.",
      image: "/images/bim-services/BIM Modeling.jpeg"
    },
    {
      icon: Layers,
      title: "Advanced BIM Services",
      description: "Clash detection, 4D/5D BIM, and facility management solutions.",
      image: "/images/bim-services/Advanced BIM.jpeg"
    },
    {
      icon: Box,
      title: "VDC Services",
      description: "Virtual Design & Construction coordination for seamless project delivery.",
      image: "/images/bim-services/VDC.jpeg"
    },
    {
      icon: Globe,
      title: "Global BIM Services",
      description: "International BIM standards compliance and consulting services.",
      image: "/images/bim-services/Global BIM.jpeg"
    },
  ];

  const stats = [
    { value: "500+", label: "Projects Completed" },
    { value: "50+", label: "Expert Team Members" },
    { value: "15+", label: "Years Experience" },
    { value: "98%", label: "Client Satisfaction" },
  ];

  // Static fallback projects
  const staticProjects = [
    {
      id: "1",
      title: "Downtown Business Center",
      category: "Commercial",
      description: "Complete BIM modeling and coordination for a 30-story mixed-use development.",
      image: "https://images.unsplash.com/photo-1486406146926-c627a92ad1ab?w=800",
    },
    {
      id: "3",
      title: "National Sports Arena",
      category: "Cultural & Sports",
      description: "Advanced structural and MEP modeling for large-scale sports facility.",
      image: "https://images.unsplash.com/photo-1540747913346-19e32dc3e97e?w=800",
    },
    {
      id: "5",
      title: "Metro Transit Station",
      category: "Infrastructure & Municipal",
      description: "Infrastructure BIM coordination for urban transit development.",
      image: "https://images.unsplash.com/photo-1517245386807-bb43f82c33c4?w=800",
    },
  ];

  // Helper function to truncate description to 30 words
  const truncateDescription = (text: string, maxWords: number = 30) => {
    if (!text) return '';
    const words = text.split(' ');
    if (words.length <= maxWords) return text;
    return words.slice(0, maxWords).join(' ') + '...';
  };

  // Fetch featured projects from database
  useEffect(() => {
    const fetchFeaturedProjects = async () => {
      const { data, error } = await supabase
        .from("projects")
        .select("*")
        .eq("published", true)
        .order("created_at", { ascending: false })
        .limit(3);

      if (data && data.length > 0) {
        // Use database projects if available
        const dbProjects = data.map((p: any) => ({
          id: p.id,
          title: p.title,
          category: p.category,
          description: truncateDescription(p.description || ''),
          image: p.image_url || "https://images.unsplash.com/photo-1486406146926-c627a92ad1ab?w=1920",
        }));
        setFeaturedProjects(dbProjects);
      } else {
        // Fallback to static projects
        setFeaturedProjects(staticProjects.map(p => ({
          ...p,
          description: truncateDescription(p.description),
        })));
      }
    };

    fetchFeaturedProjects();
  }, []);

  return (
    <div className="min-h-screen">
      <Navigation />
      
      {/* Parallax Hero Section */}
      <ParallaxHero />

      {/* Stats Section */}
      <section className="py-16 bg-secondary">
        <div className="container mx-auto px-4">
          <div className="grid grid-cols-2 md:grid-cols-4 gap-8">
            {stats.map((stat, index) => (
              <div key={index} className="text-center">
                <div className="text-4xl md:text-5xl font-bold text-primary mb-2">
                  {stat.value}
                </div>
                <div className="text-muted-foreground">{stat.label}</div>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* Services Section */}
      <section className="py-20">
        <div className="container mx-auto px-4">
          <div className="text-center mb-12">
            <h2 className="text-4xl font-bold mb-4">Our Services</h2>
            <p className="text-xl text-muted-foreground max-w-2xl mx-auto">
              Comprehensive BIM solutions tailored to your project needs
            </p>
          </div>

          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
            {services.map((service, index) => (
              <Card 
                key={index} 
                className="border-border hover:shadow-2xl transition-all duration-500 group overflow-hidden animate-fade-in-up"
                style={{ 
                  animationDelay: `${index * 150}ms`,
                  opacity: 0
                }}
              >
                {/* Image Section */}
                <div className="relative h-48 overflow-hidden">
                  <img 
                    src={service.image} 
                    alt={service.title}
                    className="w-full h-full object-cover group-hover:scale-110 transition-transform duration-700"
                  />
                  <div className="absolute inset-0 bg-gradient-to-t from-black/70 via-black/30 to-transparent" />
                </div>

                <CardHeader>
                  <CardTitle className="group-hover:text-primary transition-colors">{service.title}</CardTitle>
                </CardHeader>
                <CardContent>
                  <CardDescription className="leading-relaxed">{service.description}</CardDescription>
                </CardContent>
              </Card>
            ))}
          </div>

          <div className="text-center mt-12">
            <Link href="/services">
              <Button size="lg">
                Explore All Services
                <ArrowRight className="ml-2" size={20} />
              </Button>
            </Link>
          </div>
        </div>
      </section>

      {/* Featured Projects Section */}
      <section className="py-20 bg-secondary">
        <div className="container mx-auto px-4">
          <div className="text-center mb-12">
            <h2 className="text-4xl font-bold mb-4">Featured Projects</h2>
            <p className="text-xl text-muted-foreground max-w-2xl mx-auto">
              Showcasing our expertise across diverse building and infrastructure projects
            </p>
          </div>

          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8">
            {featuredProjects.map((project, index) => (
              <Link key={index} href={`/projects/${project.id}`}>
                <Card className="border-border overflow-hidden group hover:shadow-xl transition-all cursor-pointer h-full">
                  <div className="relative h-64 overflow-hidden">
                    <img 
                      src={project.image} 
                      alt={project.title}
                      className="w-full h-full object-cover group-hover:scale-110 transition-transform duration-500"
                      loading="lazy"
                    />
                    <div className="absolute inset-0 bg-gradient-to-t from-black/70 to-transparent" />
                    <div className="absolute bottom-4 left-4 right-4">
                      <span className="bg-primary text-primary-foreground text-xs px-3 py-1 rounded-full mb-2 inline-block">
                        {project.category}
                      </span>
                      <h3 className="text-white font-semibold text-lg line-clamp-2">{project.title}</h3>
                    </div>
                  </div>
                  <CardContent className="p-5">
                    <p className="text-muted-foreground text-sm leading-relaxed line-clamp-3">
                      {project.description}
                    </p>
                  </CardContent>
                </Card>
              </Link>
            ))}
          </div>

          <div className="text-center mt-12">
            <Link href="/projects">
              <Button size="lg" variant="outline">
                View All Projects
                <ArrowRight className="ml-2" size={20} />
              </Button>
            </Link>
          </div>
        </div>
      </section>

      {/* Why Choose Us Section */}
      <section className="py-20">
        <div className="container mx-auto px-4">
          <div className="grid grid-cols-1 lg:grid-cols-2 gap-12 items-center">
            <div>
              <h2 className="text-4xl font-bold mb-6">Why Choose BIMaided?</h2>
              <p className="text-lg text-muted-foreground mb-8">
                We deliver exceptional BIM services with a commitment to quality, innovation, and client satisfaction.
              </p>
              
              <div className="space-y-4">
                {[
                  "Industry-leading BIM expertise",
                  "Cutting-edge technology and tools",
                  "Dedicated project management",
                  "Global delivery capabilities",
                  "Proven track record of success",
                ].map((item, index) => (
                  <div key={index} className="flex items-center gap-3">
                    <CheckCircle2 className="text-primary flex-shrink-0" size={24} />
                    <span className="text-lg">{item}</span>
                  </div>
                ))}
              </div>

              <div className="mt-8">
                <Link href="/about">
                  <Button size="lg">Learn More About Us</Button>
                </Link>
              </div>
            </div>

            <div className="grid grid-cols-2 gap-4">
              <Card className="border-border">
                <CardHeader>
                  <CardTitle className="text-3xl text-primary">15+</CardTitle>
                  <CardDescription>Years of Experience</CardDescription>
                </CardHeader>
              </Card>
              <Card className="border-border">
                <CardHeader>
                  <CardTitle className="text-3xl text-primary">500+</CardTitle>
                  <CardDescription>Projects Delivered</CardDescription>
                </CardHeader>
              </Card>
              <Card className="border-border">
                <CardHeader>
                  <CardTitle className="text-3xl text-primary">50+</CardTitle>
                  <CardDescription>Team Members</CardDescription>
                </CardHeader>
              </Card>
              <Card className="border-border">
                <CardHeader>
                  <CardTitle className="text-3xl text-primary">98%</CardTitle>
                  <CardDescription>Client Satisfaction</CardDescription>
                </CardHeader>
              </Card>
            </div>
          </div>
        </div>
      </section>

      {/* CTA Section */}
      <section className="py-20">
        <div className="container mx-auto px-4">
          <Card className="bg-gradient-to-br from-sky-600 via-blue-600 to-sky-700 border-0 text-white max-w-5xl mx-auto overflow-hidden relative shadow-2xl">
            {/* Background Pattern */}
            <div className="absolute inset-0 opacity-10 bg-grid-pattern" />
            
            <CardHeader className="text-center py-16 px-6 relative z-10">
              <CardTitle className="text-3xl md:text-4xl lg:text-5xl font-bold mb-6 text-white drop-shadow-lg">
                Ready to Start Your Project?
              </CardTitle>
              <CardDescription className="text-lg md:text-xl text-white/95 mb-10 max-w-3xl mx-auto leading-relaxed">
                Let's discuss how we can help bring your vision to life with our BIM expertise
              </CardDescription>
              <div className="flex flex-col sm:flex-row gap-5 justify-center">
                <Link href="/contact">
                  <Button 
                    size="lg" 
                    className="text-base md:text-lg px-8 md:px-10 py-6 bg-white text-sky-600 hover:bg-gray-50 font-semibold shadow-xl hover:scale-105 transition-all rounded-full"
                  >
                    Get In Touch
                  </Button>
                </Link>
                <Link href="/projects">
                  <Button 
                    size="lg" 
                    variant="outline" 
                    className="text-base md:text-lg px-8 md:px-10 py-6 border-2 border-white text-white bg-transparent hover:bg-white hover:text-sky-600 font-semibold backdrop-blur-sm transition-all rounded-full shadow-lg"
                  >
                    View Our Work
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
