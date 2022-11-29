enum ConstraintType
{
	CLOSER,
	CLOSER_MERGE,
	FURTHER
}


class Constraint
{
	public int id_ball_1, id_ball_2;
	public ConstraintType type;
	public float dist;
	
	public Constraint(int ball_1, int ball_2, ConstraintType type, float dist)
	{
		id_ball_1 = ball_1;
		id_ball_2 = ball_2;
		this.type = type;
		this.dist = dist;
	}
	
	public PVector displacement(PVector pos1, PVector pos2)
	{
		PVector disp = new PVector(0, 0);

		// if closer than dist -> move
		if(type == ConstraintType.CLOSER || type == ConstraintType.CLOSER_MERGE)
		{
			PVector vector = pos1.copy().sub(pos2);
			if(vector.magSq() > dist * dist)
				return disp;
			float mag = (dist - vector.mag()) / 2.0;
			disp = vector.normalize().mult(mag);
		}
		// if further than dist -> move
		if(type == ConstraintType.FURTHER)
		{
			PVector vector = pos1.copy().sub(pos2);
			if(vector.magSq() < dist * dist)
				return disp;
			float mag = (dist - vector.mag()) / 2.0;
			disp = vector.normalize().mult(mag);
		}
		
		return disp;
  	}
}