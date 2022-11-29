enum ForceType
{
    GRAVITY,
    SIMPLE_GRAVITY,
    SPRING
}

class Force
{
    public int id_ball_1, id_ball_2;
    public ForceType type;
    public float coef;
    public float start_len;
    
    // Simple gravity
    public Force(int ball_1, ForceType type, float coef)
    {
        id_ball_1 = ball_1;
        id_ball_2 = -1;
        this.type = type;
        this.coef = coef;
    }

    // Gravity
    public Force(int ball_1, int ball_2, ForceType type, float coef)
    {
        id_ball_1 = ball_1;
        id_ball_2 = ball_2;
        this.type = type;
        this.coef = coef;
    }

    // Spring
    public Force(int ball_1, int ball_2, ForceType type, float coef, float start_len)
    {
        id_ball_1 = ball_1;
        id_ball_2 = ball_2;
        this.type = type;
        this.coef = coef;
        this.start_len = start_len;
    }

    // Calculate Force
    public PVector force(PVector pos1, PVector pos2, float mass1, float mass2)
    {
        PVector force = new PVector(0, 0);

        // process if gravity
        if(type == ForceType.GRAVITY)
        {
            PVector vector = pos1.copy().sub(pos2);
            float magSq = vector.magSq();
            vector.normalize();
            force = vector.copy().mult(-coef * mass1 * mass2 / magSq);
        }

        // process if spring
        if(type == ForceType.SPRING)
        {
            PVector vector = pos1.copy().sub(pos2);
            force = vector.copy().mult(-coef * (vector.mag() - start_len));
        }

        // process if simple gravity
        if(type == ForceType.SIMPLE_GRAVITY)
        {
            force = new PVector(0, -coef * mass1);
        }
        
        return force;
    }
}
