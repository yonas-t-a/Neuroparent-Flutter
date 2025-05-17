import jwt from 'jsonwebtoken';
import bcrypt from 'bcrypt';
import userModel from '../model/user.js';

const JWT_SECRET = process.env.JWT_SECRET || 'your-secret';

export async function login(req, res) {
    const { email, password } = req.body;

    if (!email || !password)
        return res.status(400).json({ error: "Email and password are required" });

    try {
        const user = await userModel.getUserByEmail(email);
        if (!user)
            return res.status(401).json({ error: "Invalid credentials" });

        const isMatch = await bcrypt.compare(password, user.password);
        if (!isMatch)
            return res.status(401).json({ error: "Invalid credentials" });

        const token = jwt.sign(
            { id: user.user_id, role: user.role },
            JWT_SECRET,
            { expiresIn: '1d' }
        );
        // respond all the user Informatoin
        res.status(200).json({ 
            token, 
            
         });
    } catch (error) {
        res.status(500).json({ error: "Login failed" });
    }
}

export async function register(req, res) {
    const { name, email, password } = req.body;

    if (!name || !email || !password)
        return res.status(400).json({ error: "All fields are required" });

    try {
        const existingUser = await userModel.getUserByEmail(email);
        if (existingUser)
            return res.status(409).json({ error: "User already exists" });

        const hashedPassword = await bcrypt.hash(password, 10);
        const newUser = await userModel.createUser({ name, email, password: hashedPassword });
        res.status(201).json({ message: "User registered successfully", user: newUser });
    } catch (error) {
        res.status(500).json({ error: "Registration failed" });
    }
}
