# UK International Perfumes - Deployment Guide

## Overview
This guide provides step-by-step instructions for deploying the UK International Perfumes Flutter web application to production. The app includes a customer-facing website with product browsing, cart functionality, and an admin dashboard for content management.

## Prerequisites
- A domain name (e.g., ukinternationalperfumes.com)
- A web hosting service (recommended: Vercel, Netlify, or Firebase Hosting)
- Supabase account for backend services
- Basic understanding of web deployment

## Step 1: Domain and Hosting Setup

### 1.1 Purchase Domain
- Purchase a domain from a registrar (GoDaddy, Namecheap, etc.)
- Recommended: `ukinternationalperfumes.com` or similar

### 1.2 Choose Hosting Platform
**Recommended: Vercel (Free tier available)**
- Sign up at [vercel.com](https://vercel.com)
- Connect your GitHub repository
- Configure build settings for Flutter web

**Alternative: Netlify**
- Sign up at [netlify.com](https://netlify.com)
- Connect your repository
- Set build command: `flutter build web`
- Set publish directory: `build/web`

## Step 2: Supabase Database Setup

### 2.1 Create Supabase Project
1. Go to [supabase.com](https://supabase.com)
2. Create a new project
3. Note down your project URL and anon key

### 2.2 Database Schema Setup
Run the following SQL scripts in your Supabase SQL editor:

#### Products Table
```sql
CREATE TABLE IF NOT EXISTS products (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    description TEXT NOT NULL,
    mrp DECIMAL(10,2) NOT NULL,
    offer DECIMAL(5,2) DEFAULT 0,
    price_after_offer DECIMAL(10,2) NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    image_url TEXT NOT NULL,
    category TEXT NOT NULL,
    stock INTEGER DEFAULT 0,
    is_top_selling BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

#### Carousel Images Table
```sql
CREATE TABLE IF NOT EXISTS carousel_images (
    id TEXT PRIMARY KEY,
    image_url TEXT NOT NULL,
    is_active BOOLEAN DEFAULT true,
    display_order INTEGER DEFAULT 1,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

#### Offers Table
```sql
CREATE TABLE IF NOT EXISTS offers (
    id TEXT PRIMARY KEY,
    title TEXT NOT NULL,
    description TEXT NOT NULL,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

#### Customer Reviews Table
```sql
CREATE TABLE IF NOT EXISTS customer_reviews (
    id TEXT PRIMARY KEY,
    customer_name TEXT NOT NULL,
    review_text TEXT NOT NULL,
    rating DECIMAL(3,1) NOT NULL,
    image_url TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

#### Coupons Table
```sql
CREATE TABLE IF NOT EXISTS coupons (
    id TEXT PRIMARY KEY,
    code TEXT UNIQUE NOT NULL,
    discount DECIMAL(5,2) NOT NULL,
    expiry TIMESTAMP WITH TIME ZONE NOT NULL,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

#### About Us Content Table
```sql
CREATE TABLE IF NOT EXISTS about_us_content (
    id TEXT PRIMARY KEY,
    title TEXT NOT NULL,
    subtitle TEXT NOT NULL,
    main_description TEXT NOT NULL,
    mission TEXT NOT NULL,
    vision TEXT NOT NULL,
    values TEXT NOT NULL,
    hero_image_url TEXT DEFAULT '',
    team_image_url TEXT DEFAULT '',
    features JSONB DEFAULT '[]',
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

### 2.3 Enable Row Level Security (RLS)
```sql
-- Enable RLS on all tables
ALTER TABLE products ENABLE ROW LEVEL SECURITY;
ALTER TABLE carousel_images ENABLE ROW LEVEL SECURITY;
ALTER TABLE offers ENABLE ROW LEVEL SECURITY;
ALTER TABLE customer_reviews ENABLE ROW LEVEL SECURITY;
ALTER TABLE coupons ENABLE ROW LEVEL SECURITY;
ALTER TABLE about_us_content ENABLE ROW LEVEL SECURITY;

-- Create policies for public read access
CREATE POLICY "Allow public read access to products" ON products FOR SELECT USING (true);
CREATE POLICY "Allow public read access to active carousel images" ON carousel_images FOR SELECT USING (is_active = true);
CREATE POLICY "Allow public read access to active offers" ON offers FOR SELECT USING (is_active = true);
CREATE POLICY "Allow public read access to active reviews" ON customer_reviews FOR SELECT USING (is_active = true);
CREATE POLICY "Allow public read access to active coupons" ON coupons FOR SELECT USING (is_active = true);
CREATE POLICY "Allow public read access to active about us content" ON about_us_content FOR SELECT USING (is_active = true);

-- Create policies for authenticated users (admin access)
CREATE POLICY "Allow authenticated users to manage products" ON products FOR ALL USING (auth.role() = 'authenticated');
CREATE POLICY "Allow authenticated users to manage carousel images" ON carousel_images FOR ALL USING (auth.role() = 'authenticated');
CREATE POLICY "Allow authenticated users to manage offers" ON offers FOR ALL USING (auth.role() = 'authenticated');
CREATE POLICY "Allow authenticated users to manage reviews" ON customer_reviews FOR ALL USING (auth.role() = 'authenticated');
CREATE POLICY "Allow authenticated users to manage coupons" ON coupons FOR ALL USING (auth.role() = 'authenticated');
CREATE POLICY "Allow authenticated users to manage about us content" ON about_us_content FOR ALL USING (auth.role() = 'authenticated');
```

### 2.4 Insert Default Content
```sql
-- Insert default about us content
INSERT INTO about_us_content (
    id, title, subtitle, main_description, mission, vision, values, features, is_active
) VALUES (
    'default-about-us',
    'About UK International',
    'Crafting Luxury Fragrances for the Modern World',
    'UK International Perfumes is a premium fragrance house dedicated to creating exceptional scents that capture the essence of luxury and sophistication. Our journey began with a passion for authentic fragrances and a commitment to quality that transcends trends.',
    'To create exceptional fragrances that inspire confidence and evoke emotions, while maintaining the highest standards of quality and authenticity.',
    'To become the leading destination for luxury fragrances, known for our commitment to quality, innovation, and customer satisfaction.',
    'We believe in creating fragrances that not only smell incredible but also tell a story. Our values are rooted in quality, authenticity, and the pursuit of excellence in every aspect of our business.',
    '["Premium Quality Ingredients", "Cruelty-Free Practices", "Luxury Experience", "Unique Fragrances", "Customer Satisfaction", "Innovation"]',
    true
) ON CONFLICT (id) DO NOTHING;
```

## Step 3: Storage Setup

### 3.1 Create Storage Buckets
In Supabase Dashboard > Storage, create the following buckets:
- `carousel-images` (for carousel images)
- `review-images` (for customer review images)
- `about-us-images` (for about us page images)

### 3.2 Storage Policies
```sql
-- Carousel images bucket policies
CREATE POLICY "Allow public read access to carousel images" ON storage.objects
    FOR SELECT USING (bucket_id = 'carousel-images');

CREATE POLICY "Allow authenticated users to upload carousel images" ON storage.objects
    FOR INSERT WITH CHECK (bucket_id = 'carousel-images' AND auth.role() = 'authenticated');

-- Review images bucket policies
CREATE POLICY "Allow public read access to review images" ON storage.objects
    FOR SELECT USING (bucket_id = 'review-images');

CREATE POLICY "Allow authenticated users to upload review images" ON storage.objects
    FOR INSERT WITH CHECK (bucket_id = 'review-images' AND auth.role() = 'authenticated');

-- About us images bucket policies
CREATE POLICY "Allow public read access to about us images" ON storage.objects
    FOR SELECT USING (bucket_id = 'about-us-images');

CREATE POLICY "Allow authenticated users to upload about us images" ON storage.objects
    FOR INSERT WITH CHECK (bucket_id = 'about-us-images' AND auth.role() = 'authenticated');
```

## Step 4: Admin User Creation

### 4.1 Create Admin User
1. Go to Supabase Dashboard > Authentication > Users
2. Click "Add User" or "Invite User"
3. Enter admin email and password
4. The user can now login to the admin dashboard

### 4.2 Admin Dashboard Access
- Navigate to `yourdomain.com/admin-login`
- Use the created admin credentials
- Access the full admin dashboard with all management features

## Step 5: Environment Configuration

### 5.1 Update Environment Variables
In your hosting platform, set these environment variables:
```
SUPABASE_URL=your_supabase_project_url
SUPABASE_ANON_KEY=your_supabase_anon_key
```

### 5.2 Update App Constants
Ensure `lib/core/config/environment.dart` points to your production Supabase project.

## Step 6: Build and Deploy

### 6.1 Build the App
```bash
flutter build web --release
```

### 6.2 Deploy to Hosting
- Upload the contents of `build/web/` to your hosting platform
- Configure your domain to point to the hosting service

## Step 7: Content Population

### 7.1 Add Products
1. Login to admin dashboard
2. Go to Products tab
3. Add products with categories:
   - Premium Perfumes
   - Luxury Perfumes
   - Arabic Perfumes

### 7.2 Add Carousel Images
1. Go to Carousel tab
2. Upload hero images for the homepage

### 7.3 Add Offers
1. Go to Offers tab
2. Create promotional offers

### 7.4 Add Customer Reviews
1. Go to Reviews tab
2. Add customer testimonials with images

### 7.5 Configure About Us Page
1. Go to About Us tab
2. Customize the content, mission, vision, and values
3. Upload hero and team images

### 7.6 Add Coupons
1. Go to Coupons tab
2. Create discount coupons

## Step 8: Testing

### 8.1 Functionality Testing
- [ ] Homepage loads correctly
- [ ] Product browsing works
- [ ] Category filtering works
- [ ] Search functionality works
- [ ] Cart functionality works
- [ ] About Us page displays correctly
- [ ] Admin login works
- [ ] Admin dashboard functions properly
- [ ] Image uploads work
- [ ] WhatsApp integration works

### 8.2 Responsive Testing
- [ ] Mobile view works correctly
- [ ] Tablet view works correctly
- [ ] Desktop view works correctly

## Step 9: Post-Launch

### 9.1 SEO Setup
- Add meta tags for better search engine visibility
- Submit sitemap to search engines
- Set up Google Analytics

### 9.2 Monitoring
- Set up error monitoring
- Monitor performance metrics
- Set up uptime monitoring

### 9.3 Maintenance
- Regular content updates
- Security updates
- Performance optimizations

## Troubleshooting

### Common Issues
1. **Images not loading**: Check storage bucket policies
2. **Admin access denied**: Verify user authentication in Supabase
3. **Build failures**: Check environment variables
4. **Database errors**: Verify RLS policies

### Support
For technical support, contact the development team or refer to the Flutter and Supabase documentation.

## Security Notes
- Keep admin credentials secure
- Regularly update dependencies
- Monitor for security vulnerabilities
- Use HTTPS in production
- Implement proper backup strategies

---

**Last Updated**: January 2025
**Version**: 2.0 