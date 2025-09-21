-- Create about_us_content table
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