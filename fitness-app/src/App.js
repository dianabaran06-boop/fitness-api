import { useEffect, useState } from "react";
import "./App.css";

const API_URL = "https://i0hta7ddlf.execute-api.eu-central-1.amazonaws.com/dev";

function App() {
  const [workouts, setWorkouts] = useState([]);

  const getWorkouts = async () => {
    const res = await fetch(`${API_URL}/workouts`);
    const data = await res.json();
    setWorkouts(data);
  };

  const createWorkout = async () => {
    await fetch(`${API_URL}/workouts`, {
      method: "POST",
      body: JSON.stringify({
        id: Date.now().toString(),
        name: "Test workout",
      }),
    });
    getWorkouts();
  };

  const deleteWorkout = async (id) => {
    await fetch(`${API_URL}/workouts/${id}`, {
      method: "DELETE",
    });
    getWorkouts();
  };

  useEffect(() => {
    getWorkouts();
  }, []);

  return (
    <div style={{ padding: "20px" }}>
      <h1>Fitness App</h1>

      <button onClick={getWorkouts}>Get Workouts</button>
      <button onClick={createWorkout}>Add Workout</button>

      <ul>
        {workouts.map((w) => (
          <li key={w.id}>
            {w.name}
            <button onClick={() => deleteWorkout(w.id)}>❌</button>
          </li>
        ))}
      </ul>
    </div>
  );
}

export default App;
