import Navigation from "@/components/Navigation";
import Footer from "@/components/Footer";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { Calendar, User } from "lucide-react";

const Blog = () => {
  const posts = [
    {
      title: "The Future of BIM in Construction Industry",
      excerpt: "Explore how Building Information Modeling is transforming the construction landscape and what lies ahead.",
      author: "John Smith",
      date: "January 15, 2024",
      image: "https://images.unsplash.com/photo-1503387762-592deb58ef4e?w=800",
      category: "Industry Trends",
    },
    {
      title: "5 Benefits of Implementing BIM in Your Projects",
      excerpt: "Discover the key advantages that BIM brings to construction projects of all sizes.",
      author: "Sarah Johnson",
      date: "January 10, 2024",
      image: "https://images.unsplash.com/photo-1454165804606-c3d57bc86b40?w=800",
      category: "Best Practices",
    },
    {
      title: "Clash Detection: Saving Time and Costs",
      excerpt: "Learn how early clash detection in BIM can prevent costly on-site conflicts and delays.",
      author: "Michael Chen",
      date: "January 5, 2024",
      image: "https://images.unsplash.com/photo-1497366811353-6870744d04b2?w=800",
      category: "Technology",
    },
    {
      title: "BIM Standards and Compliance Guide",
      excerpt: "A comprehensive overview of international BIM standards and how to ensure compliance.",
      author: "Emily Davis",
      date: "December 28, 2023",
      image: "https://images.unsplash.com/photo-1450101499163-c8848c66ca85?w=800",
      category: "Standards",
    },
    {
      title: "Sustainable Building with BIM",
      excerpt: "How BIM contributes to sustainable construction practices and environmental goals.",
      author: "David Wilson",
      date: "December 20, 2023",
      image: "https://images.unsplash.com/photo-1497366216548-37526070297c?w=800",
      category: "Sustainability",
    },
    {
      title: "VDC vs Traditional Construction Methods",
      excerpt: "Understanding the advantages of Virtual Design and Construction over conventional approaches.",
      author: "Lisa Anderson",
      date: "December 15, 2023",
      image: "https://images.unsplash.com/photo-1454165804606-c3d57bc86b40?w=800",
      category: "Comparison",
    },
  ];

  return (
    <div className="min-h-screen">
      <Navigation />
      
      {/* Hero Section */}
      <section className="pt-32 pb-16 bg-gradient-to-b from-secondary to-background">
        <div className="container mx-auto px-4">
          <div className="max-w-3xl mx-auto text-center">
            <h1 className="text-5xl font-bold mb-6">Our Blog</h1>
            <p className="text-xl text-muted-foreground">
              Insights, updates, and best practices from the world of BIM
            </p>
          </div>
        </div>
      </section>

      {/* Blog Posts Grid */}
      <section className="py-16">
        <div className="container mx-auto px-4">
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8">
            {posts.map((post, index) => (
              <Card key={index} className="border-border overflow-hidden hover:shadow-xl transition-all group cursor-pointer">
                <div className="relative h-48 overflow-hidden">
                  <img 
                    src={post.image} 
                    alt={post.title}
                    className="w-full h-full object-cover group-hover:scale-110 transition-transform duration-300"
                  />
                  <div className="absolute top-4 left-4">
                    <span className="bg-primary text-primary-foreground text-xs px-3 py-1 rounded-full">
                      {post.category}
                    </span>
                  </div>
                </div>
                <CardHeader>
                  <CardTitle className="group-hover:text-primary transition-colors">
                    {post.title}
                  </CardTitle>
                  <CardDescription>{post.excerpt}</CardDescription>
                </CardHeader>
                <CardContent>
                  <div className="flex items-center gap-4 text-sm text-muted-foreground">
                    <div className="flex items-center gap-1">
                      <User size={14} />
                      <span>{post.author}</span>
                    </div>
                    <div className="flex items-center gap-1">
                      <Calendar size={14} />
                      <span>{post.date}</span>
                    </div>
                  </div>
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

export default Blog;
