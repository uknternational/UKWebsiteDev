-- UK International Perfumes Database Setup
-- Run these SQL commands in your Supabase SQL Editor

-- 1. Carousel Images Table
CREATE TABLE IF NOT EXISTS carousel_images (
    id TEXT PRIMARY KEY,
    image_url TEXT NOT NULL,
    is_active BOOLEAN DEFAULT true,
    display_order INTEGER DEFAULT 1,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 2. Offers Table
CREATE TABLE IF NOT EXISTS offers (
    id TEXT PRIMARY KEY,
    title TEXT NOT NULL,
    description TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 3. Customer Reviews Table
CREATE TABLE IF NOT EXISTS customer_reviews (
    id TEXT PRIMARY KEY,
    customer_name TEXT NOT NULL,
    review_text TEXT NOT NULL,
    rating DECIMAL(2,1) CHECK (rating >= 0 AND rating <= 5),
    image_url TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 4. Cart Items Table
CREATE TABLE IF NOT EXISTS cart_items (
    id TEXT PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    product_id TEXT NOT NULL REFERENCES products(id) ON DELETE CASCADE,
    quantity INTEGER NOT NULL DEFAULT 1,
    added_at TIMESTAMPTZ DEFAULT NOW()
);

-- 5. Wishlist Items Table
CREATE TABLE IF NOT EXISTS wishlist_items (
    id TEXT PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    product_id TEXT NOT NULL REFERENCES products(id) ON DELETE CASCADE,
    added_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(user_id, product_id)
);

-- 6. Create Storage Bucket (if not exists)
-- Note: Run this in the Storage section of Supabase Dashboard
-- Bucket name: 'images'
-- Public: true

-- 7. Set up Row Level Security (RLS) Policies

-- Carousel Images Policies
ALTER TABLE carousel_images ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Allow public read access on carousel_images" ON carousel_images
    FOR SELECT USING (true);

CREATE POLICY "Allow authenticated insert on carousel_images" ON carousel_images
    FOR INSERT TO authenticated WITH CHECK (true);

CREATE POLICY "Allow authenticated update on carousel_images" ON carousel_images
    FOR UPDATE TO authenticated USING (true);

CREATE POLICY "Allow authenticated delete on carousel_images" ON carousel_images
    FOR DELETE TO authenticated USING (true);

-- Offers Policies
ALTER TABLE offers ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Allow public read access on offers" ON offers
    FOR SELECT USING (true);

CREATE POLICY "Allow authenticated insert on offers" ON offers
    FOR INSERT TO authenticated WITH CHECK (true);

CREATE POLICY "Allow authenticated update on offers" ON offers
    FOR UPDATE TO authenticated USING (true);

CREATE POLICY "Allow authenticated delete on offers" ON offers
    FOR DELETE TO authenticated USING (true);

-- Customer Reviews Policies
ALTER TABLE customer_reviews ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Allow public read access on customer_reviews" ON customer_reviews
    FOR SELECT USING (true);

CREATE POLICY "Allow authenticated insert on customer_reviews" ON customer_reviews
    FOR INSERT TO authenticated WITH CHECK (true);

CREATE POLICY "Allow authenticated update on customer_reviews" ON customer_reviews
    FOR UPDATE TO authenticated USING (true);

CREATE POLICY "Allow authenticated delete on customer_reviews" ON customer_reviews
    FOR DELETE TO authenticated USING (true);

-- Cart Items Policies
ALTER TABLE cart_items ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can manage their own cart items" ON cart_items
    FOR ALL USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);

-- Wishlist Policies
ALTER TABLE wishlist_items ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can manage their own wishlist" ON wishlist_items
    FOR ALL USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);

-- 8. About Us Content Table
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

-- Enable Row Level Security
ALTER TABLE about_us_content ENABLE ROW LEVEL SECURITY;

-- Create policies
-- Allow public read access to active content
CREATE POLICY "Allow public read access to active about us content" ON about_us_content
    FOR SELECT USING (is_active = true);

-- Allow authenticated users to manage all content
CREATE POLICY "Allow authenticated users to manage about us content" ON about_us_content
    FOR ALL USING (auth.role() = 'authenticated');

-- Insert default content
INSERT INTO about_us_content (
    id,
    title,
    subtitle,
    main_description,
    mission,
    vision,
    values,
    features,
    is_active
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

-- 9. Update Products table to ensure is_top_selling column exists
ALTER TABLE products ADD COLUMN IF NOT EXISTS is_top_selling BOOLEAN DEFAULT false;

-- 9. Storage Policies for the 'images' bucket
-- Note: Add these policies in the Storage > Policies section

-- Policy for SELECT (public read)
-- CREATE POLICY "Give public read access to images bucket" ON storage.objects 
-- FOR SELECT USING (bucket_id = 'images');

-- Policy for INSERT (authenticated users can upload)
-- CREATE POLICY "Give authenticated users upload access to images bucket" ON storage.objects 
-- FOR INSERT TO authenticated WITH CHECK (bucket_id = 'images');

-- Policy for DELETE (authenticated users can delete)
-- CREATE POLICY "Give authenticated users delete access to images bucket" ON storage.objects 
-- FOR DELETE TO authenticated USING (bucket_id = 'images');

-- 10. Sample Data (Optional)

-- Sample Carousel Images
INSERT INTO carousel_images (id, image_url, is_active, display_order) VALUES 
('carousel_1', 'https://images.unsplash.com/photo-1517841905240-472988babdf9?auto=format&fit=crop&w=800&q=80', true, 1),
('carousel_2', 'https://images.unsplash.com/photo-1506744038136-46273834b3fb?auto=format&fit=crop&w=800&q=80', true, 2),
('carousel_3', 'https://images.unsplash.com/photo-1465101046530-73398c7f28ca?auto=format&fit=crop&w=800&q=80', true, 3)
ON CONFLICT (id) DO NOTHING;

-- Sample Offers
INSERT INTO offers (id, title, description, is_active) VALUES 
('offer_1', 'Buy Any 3 for ₹999', 'Mix & match your favorites!', true),
('offer_2', '2 for ₹649', 'Best combos for you.', true),
('offer_3', 'Self Care Kit', '12 for ₹1298 only!', true)
ON CONFLICT (id) DO NOTHING;

-- Sample Customer Reviews
INSERT INTO customer_reviews (id, customer_name, review_text, rating, is_active) VALUES 
('review_1', 'Sanna Thakur', 'UKInternational has raised the bar for the perfume industry. Such good quality at very affordable price.', 4.5, true),
('review_2', 'Amit Sharma', 'Amazing fragrances and fast delivery! Highly recommended.', 5.0, true),
('review_3', 'Priya Singh', 'Loved the packaging and the scent lasts all day.', 4.0, true)
ON CONFLICT (id) DO NOTHING;

-- INSTRUCTIONS:
-- 1. Copy and run this entire script in your Supabase SQL Editor
-- 2. Create a storage bucket named 'images' in the Storage section
-- 3. Set the bucket to be public
-- 4. Add the storage policies mentioned in comments above
-- 5. Test the application with the new features! 